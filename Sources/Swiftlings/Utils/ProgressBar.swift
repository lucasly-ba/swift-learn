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

  /// Get a formatted progress string with bar and percentage
  func formattedProgress() -> String {
    let bar = render()
    let percentageStr = String(format: "%.0f%%", Double(completed) / Double(total) * 100)
    return "Progress: \(bar) \(completed)/\(total) (\(percentageStr))"
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
  func renderWatchMode(currentExercise: Exercise, result: ExerciseResult? = nil, showError: Bool = false) {
    Terminal.clear()

    if let result = result {
      renderResult(result)
    }

    if !showError, let result = result, result.isSuccess {
      renderDoneHeader(currentExercise)
    }

    renderProgressBar(currentExercise: currentExercise)

    renderCommandsFooter()
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
    let progressBar = ProgressBar(completed: stats.completed, total: stats.total, width: Configuration.UI.progressBarWidth)

    print(progressBar.formattedProgress())
    print("Current exercise: \(Terminal.colored(currentExercise.filePath, color: .cyan))")
    print("")
  }

  private func renderResult(_ result: ExerciseResult) {
    switch result {
      case .success(let output):
        print("Output".underline)
        print("")
        if !output.isEmpty {
          print(output)
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

  private func renderCommandsFooter() {
    func key(_ k: String, _ label: String) -> String { "\(k.bold):\(label)" }
    let menu = [
      key("n", "next"),
      key("h", "hint"),
      key("l", "list"),
      key("c", "check all"),
      key("x", "reset"),
      key("q", "quit"),
    ].joined(separator: " / ")
    print("\(menu) ? ", terminator: "")
    fflush(nil)
  }
}
