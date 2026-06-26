import Foundation
import Rainbow

/// A terminal progress bar component similar to Rustlings
struct ProgressBar {
  let completed: Int
  let total: Int
  let width: Int

  init(completed: Int, total: Int, width: Int = 80) {
    self.completed = completed
    self.total = total
    self.width = width
  }

  /// Generate the progress bar string
  func render() -> String {
    guard total > 0 else { return "[No exercises]" }

    let percentage = Double(completed) / Double(total)
    let filledWidth = Int(Double(width) * percentage)
    let emptyWidth = width - filledWidth

    var bar = "["

    if filledWidth > 0 {
      bar += String(repeating: "#", count: filledWidth - 1)
      if filledWidth < width {
        bar += ">"
      } else {
        bar += "#"
      }
    }

    if emptyWidth > 0 {
      bar += String(repeating: "-", count: emptyWidth)
    }

    bar += "]"

    return bar
  }

  /// A full progress line sized to fit the current terminal width on one line,
  /// so the bar never wraps. The bar grows or shrinks with the window.
  func formattedProgress() -> String {
    let counts = " \(completed)/\(total)"
    // "Progress: " is 10 columns and the bar adds 2 for its brackets; leave one
    // spare column so a full bar never tips onto a second line.
    let fixed = 10 + 2 + counts.count + 1
    let fitWidth = max(10, Terminal.width() - fixed)
    let bar = ProgressBar(completed: completed, total: total, width: fitWidth).render()
    return "Progress: \(bar)\(counts)"
  }
}

struct SwiftlingsUI {
  private let manager: ExerciseManager

  init(manager: ExerciseManager) {
    self.manager = manager
  }

  /// Render the watch screen the way Rustlings does: the exercise output (or
  /// compiler error) at the top, then the "done" status, then the progress bar
  /// and current exercise path, and the key menu pinned at the bottom.
  func renderWatchMode(currentExercise: Exercise, result: ExerciseResult? = nil, showHint: Bool = false) {
    Terminal.clear()

    if let result = result {
      renderResult(result)
    }

    let solved = result?.isSuccess ?? false

    if solved {
      renderDoneHeader(currentExercise)
    }

    if showHint {
      renderHint(currentExercise)
    }

    renderProgressBar(currentExercise: currentExercise)

    renderCommandsFooter(solved: solved, showHint: showHint)
  }

  private func renderHint(_ exercise: Exercise) {
    print("Hint".blue.underline)
    print(exercise.hint)
    if let doc = exercise.doc {
      print("")
      print("📖 Read more: \(doc)")
    }
    print("")
  }

  private func renderDoneHeader(_ exercise: Exercise) {
    print("Exercise done ✓".green)
    if let solution = solutionPath(for: exercise) {
      print("Solution for comparison: \(solution.underline)")
    }
    print("When done experimenting, enter `n` to move on to the next exercise 🦉")
    print("")
  }

  private func renderProgressBar(currentExercise: Exercise) {
    let stats = manager.getProgressStats()
    let progressBar = ProgressBar(completed: stats.completed, total: stats.total)

    print(progressBar.formattedProgress())
    print("Current exercise: \(Terminal.colored(currentExercise.filePath, color: .cyan))")
    print("")
  }

  private func renderResult(_ result: ExerciseResult) {
    switch result {
      case .success(let output):
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
          print("Output".underline)
          print("")
          print(trimmed)
        }

      case .compilationError(let message):
        Terminal.error("Compilation error:")
        print(message)

      case .testFailure(let message):
        Terminal.error("Test failure:")
        print(message)
    }
    print("")
  }

  /// The relative path of the matching solution file, if one ships with the
  /// exercises. Swiftlings has no solutions yet, so this is normally nil and the
  /// "Solution for comparison" line is simply not shown.
  private func solutionPath(for exercise: Exercise) -> String? {
    let cwd = FileManager.default.currentDirectoryPath
    for dir in ["Solutions", "solutions"] {
      let relative = "\(dir)/\(exercise.dir)/\(exercise.name).swift"
      if FileManager.default.fileExists(atPath: "\(cwd)/\(relative)") {
        return relative
      }
    }
    return nil
  }

  private func renderCommandsFooter(solved: Bool, showHint: Bool) {
    func key(_ k: String, _ label: String) -> String { "\(k.bold):\(label)" }
    var menu: [String] = []
    if solved { menu.append(key("n", "next")) }
    if !showHint { menu.append(key("h", "hint")) }
    menu.append(contentsOf: [
      key("l", "list"),
      key("c", "check all"),
      key("x", "reset"),
      key("q", "quit"),
    ])
    print("\(menu.joined(separator: " / ")) ? ", terminator: "")
    fflush(nil)
  }
}
