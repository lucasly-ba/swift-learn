import Foundation
import Rainbow

/// An interactive, full-screen exercise list (the `l` key in watch mode),
/// modelled on the Rustlings list: a Current / State / Name / Path table you
/// navigate with the arrows or j/k, jump around with g/G (home/end), filter by
/// state, search by name, reset, or jump to an exercise and continue there.
struct ExerciseListView {
  let manager: ExerciseManager
  let input: RawTerminalInput

  private enum Filter { case all, done, pending }

  // Column widths (display columns). The Current and State cells are padded so
  // the header lines up with the rows.
  private let currentWidth = 9
  private let stateWidth = 9

  /// Run the list until the user quits it. Returns the exercise to continue at
  /// (when they press `c`), or nil to stay on the current exercise.
  func run() -> Exercise? {
    let all = manager.getAllExercises()
    let nameWidth = max(4, all.map { $0.name.count }.max() ?? 4) + 2

    var filter = Filter.all
    var search = ""
    var offset = 0

    func filtered() -> [Exercise] {
      all.filter { exercise in
        let stateOK: Bool
        switch filter {
          case .all: stateOK = true
          case .done: stateOK = manager.isCompleted(exercise.name)
          case .pending: stateOK = !manager.isCompleted(exercise.name)
        }
        let needle = search.lowercased()
        let searchOK = needle.isEmpty
          || exercise.name.lowercased().contains(needle)
          || exercise.filePath.lowercased().contains(needle)
        return stateOK && searchOK
      }
    }

    // Start the cursor on the current exercise.
    let currentName = manager.getCurrentExercise()?.name
    var cursor = filtered().firstIndex { $0.name == currentName } ?? 0

    while true {
      let items = filtered()
      cursor = items.isEmpty ? 0 : min(max(0, cursor), items.count - 1)
      let lastIndex = max(0, items.count - 1)

      let viewportRows = max(3, Terminal.height() - 8)
      if cursor < offset { offset = cursor }
      if cursor >= offset + viewportRows { offset = cursor - viewportRows + 1 }
      offset = max(0, min(offset, max(0, items.count - viewportRows)))

      Terminal.clear()

      // Header, built with the same column widths as the rows so they align.
      print(pad("Current", currentWidth).bold
        + pad("State", stateWidth).bold
        + pad("Name", nameWidth).bold
        + "Path".bold)

      if items.isEmpty {
        print("\n  (no exercises match)")
      }
      let upper = min(offset + viewportRows, items.count)
      for index in offset..<upper {
        let exercise = items[index]
        let done = manager.isCompleted(exercise.name)
        let isCurrent = exercise.name == currentName
        let isCursor = index == cursor

        let stateText = pad(done ? "DONE" : "PENDING", stateWidth)
        let nameText = pad(exercise.name, nameWidth)

        if isCursor {
          // Selected row: the owl in the Current column and a reverse-video
          // highlight over a plain line so it covers cleanly.
          let current = padDisplay("🦉", display: 2, to: currentWidth)
          print("\u{001B}[7m\(current)\(stateText)\(nameText)\(exercise.filePath)\u{001B}[0m")
        } else {
          let current = isCurrent
            ? padDisplay(">>>>>>>".red, display: 7, to: currentWidth)
            : String(repeating: " ", count: currentWidth)
          let state = done ? stateText.green : stateText.yellow
          let path = Terminal.colored(exercise.filePath, color: .cyan).underline
          print("\(current)\(state)\(nameText)\(path)")
        }
      }

      let stats = manager.getProgressStats()
      print("")
      print(ProgressBar(completed: stats.completed, total: stats.total).formattedProgress())
      printFooter(filter: filter, search: search)

      let key = input.waitForKey()

      // Arrow / Home / End keys arrive as ESC [ ...
      if key == "\u{1B}" {
        guard input.readKeyIfAvailable() == "[", let dir = input.readKeyIfAvailable() else { continue }
        switch dir {
          case "A": cursor = max(0, cursor - 1)
          case "B": cursor = min(lastIndex, cursor + 1)
          case "H": cursor = 0; offset = 0
          case "F": cursor = lastIndex
          case "1", "7": cursor = 0; offset = 0; _ = input.readKeyIfAvailable()
          case "4", "8": cursor = lastIndex; _ = input.readKeyIfAvailable()
          default: break
        }
        continue
      }

      switch key {
        case "j": cursor = min(lastIndex, cursor + 1)
        case "k": cursor = max(0, cursor - 1)
        case "g": cursor = 0; offset = 0
        case "G": cursor = lastIndex
        case "d": filter = (filter == .done) ? .all : .done; cursor = 0; offset = 0
        case "p": filter = (filter == .pending) ? .all : .pending; cursor = 0; offset = 0
        case "s":
          search = readSearch(initial: search)
          cursor = 0; offset = 0
        case "r":
          if !items.isEmpty { confirmAndReset(items[cursor]) }
        case "c":
          if items.isEmpty { return nil }
          let chosen = items[cursor]
          manager.setCurrentExercise(chosen)
          return chosen
        case "q", "\u{04}":
          return nil
        default:
          break
      }
    }
  }

  private func printFooter(filter: Filter, search: String) {
    func bracket(_ letter: String, _ rest: String, active: Bool = false) -> String {
      let inner = "<\(letter.bold)>\(rest)"
      return active ? inner.underline : inner
    }
    print("↓/j ↑/k home/g end/G | \(bracket("c", "ontinue at")) | \(bracket("r", "eset exercise"))")
    let doneTag = bracket("d", "one", active: filter == .done)
    let pendingTag = bracket("p", "ending", active: filter == .pending)
    var line = "\(bracket("s", "earch")) | filter \(doneTag)/\(pendingTag) | \(bracket("q", "uit list"))"
    if !search.isEmpty { line += "   search: \(search)" }
    print(line + " ", terminator: "")
    fflush(nil)
  }

  /// Confirm, then reset the exercise's file to its original state (discarding
  /// the user's changes) and clear its completion. Shows a prompt and a result
  /// message on the bottom line so the user can see it happened; the next loop
  /// re-renders the list with the row flipped back to PENDING.
  private func confirmAndReset(_ exercise: Exercise) {
    Terminal.moveCursor(to: (row: Terminal.height(), column: 1))
    print("\u{001B}[2KReset \(exercise.name)? This discards your changes to \(exercise.filePath) (y/n) ", terminator: "")
    fflush(nil)
    guard String(input.waitForKey()).lowercased() == "y" else { return }

    Terminal.moveCursor(to: (row: Terminal.height(), column: 1))
    do {
      try manager.resetExerciseAndProgress(exercise)
      print("\u{001B}[2K" + "Reset \(exercise.name).".green, terminator: "")
    } catch {
      print("\u{001B}[2K" + "Failed to reset \(exercise.name): \(error.localizedDescription)".red, terminator: "")
    }
    fflush(nil)
    Thread.sleep(forTimeInterval: 1)
  }

  /// A small inline search prompt: type to filter, Backspace to edit, Enter to
  /// apply, Esc to clear.
  private func readSearch(initial: String) -> String {
    var text = initial
    while true {
      Terminal.moveCursor(to: (row: Terminal.height(), column: 1))
      print("\u{001B}[2KSearch (Enter to apply, Esc to clear): \(text)", terminator: "")
      fflush(nil)
      let key = input.waitForKey()
      if key == "\n" || key == "\r" { return text }
      if key == "\u{1B}" { return "" }
      if key == "\u{7F}" || key == "\u{08}" {
        if !text.isEmpty { text.removeLast() }
        continue
      }
      if key.isLetter || key.isNumber || key == "_" || key == "-" || key == " " {
        text.append(key)
      }
    }
  }

  private func pad(_ text: String, _ width: Int) -> String {
    text.count >= width ? text : text + String(repeating: " ", count: width - text.count)
  }

  /// Pad a cell whose visible content is `display` columns wide (used for the
  /// owl emoji, which is two columns but one Character, and for already-colored
  /// markers) out to `width` display columns.
  private func padDisplay(_ content: String, display: Int, to width: Int) -> String {
    content + String(repeating: " ", count: max(0, width - display))
  }
}
