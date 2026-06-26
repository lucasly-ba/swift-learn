import Foundation

/// An interactive, full-screen exercise list (the `l` key in watch mode),
/// modelled on the Rustlings list: navigate with the arrows or j/k, jump to the
/// top/bottom with g/G, filter by state, search by name, reset, or jump to an
/// exercise and continue there.
struct ExerciseListView {
  let manager: ExerciseManager
  let input: RawTerminalInput

  private enum Filter { case all, done, pending }

  /// Run the list until the user quits it. Returns the exercise to continue at
  /// (when they press `c`), or nil to stay on the current exercise.
  func run() -> Exercise? {
    let all = manager.getAllExercises()
    let nameWidth = max(4, all.map { $0.name.count }.max() ?? 4) + 2

    var filter = Filter.all
    var search = ""
    var cursor = 0
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

    while true {
      let items = filtered()
      cursor = items.isEmpty ? 0 : min(max(0, cursor), items.count - 1)

      let currentName = manager.getCurrentExercise()?.name
      let viewportRows = max(3, Terminal.height() - 7)
      if cursor < offset { offset = cursor }
      if cursor >= offset + viewportRows { offset = cursor - viewportRows + 1 }
      offset = max(0, min(offset, max(0, items.count - viewportRows)))

      Terminal.clear()
      print("   " + "State".bold + "    " + pad("Name", nameWidth).bold + "Path".bold)

      if items.isEmpty {
        print("\n  (no exercises match)")
      }
      let upper = min(offset + viewportRows, items.count)
      for index in offset..<upper {
        let exercise = items[index]
        let done = manager.isCompleted(exercise.name)
        let marker = exercise.name == currentName ? "🦉" : "  "
        let stateText = pad(done ? "DONE" : "PENDING", 8)
        let nameText = pad(exercise.name, nameWidth)

        if index == cursor {
          // Reverse-video highlight on a plain line so it covers cleanly.
          print("\u{001B}[7m\(marker) \(stateText)\(nameText)\(exercise.filePath)\u{001B}[0m")
        } else {
          let state = done ? stateText.green : stateText.yellow
          let path = Terminal.colored(exercise.filePath, color: .cyan).underline
          print("\(marker) \(state)\(nameText)\(path)")
        }
      }

      let stats = manager.getProgressStats()
      print("")
      print(ProgressBar(completed: stats.completed, total: stats.total).formattedProgress())

      var footerSuffix = ""
      switch filter {
        case .all: break
        case .done: footerSuffix += "  [done only]"
        case .pending: footerSuffix += "  [pending only]"
      }
      if !search.isEmpty { footerSuffix += "  search: \(search)" }

      print("\("↑/k".bold) \("↓/j".bold) \("g".bold)/\("G".bold) | "
        + "\("c".bold):continue at | \("r".bold):reset | "
        + "\("s".bold):search | \("d".bold):done \("p".bold):pending | \("q".bold):quit"
        + footerSuffix + " ", terminator: "")
      fflush(nil)

      let key = input.waitForKey()

      // Arrow keys arrive as ESC [ A/B.
      if key == "\u{1B}" {
        if input.readKeyIfAvailable() == "[", let dir = input.readKeyIfAvailable() {
          if dir == "A" { cursor = max(0, cursor - 1) }
          else if dir == "B" { cursor = min(max(0, items.count - 1), cursor + 1) }
        }
        continue
      }

      switch key {
        case "j": cursor = min(max(0, items.count - 1), cursor + 1)
        case "k": cursor = max(0, cursor - 1)
        case "g": cursor = 0; offset = 0
        case "G": cursor = max(0, items.count - 1)
        case "d": filter = (filter == .done) ? .all : .done; cursor = 0; offset = 0
        case "p": filter = (filter == .pending) ? .all : .pending; cursor = 0; offset = 0
        case "s":
          search = readSearch(initial: search)
          cursor = 0; offset = 0
        case "r":
          if !items.isEmpty { try? manager.resetExercise(items[cursor]) }
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
}
