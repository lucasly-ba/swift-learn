import ArgumentParser
import Foundation

struct WatchCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "watch",
    abstract: "Watch exercises"
  )

  func run() throws {
    let manager = try ExerciseManager()
    let ui = SwiftlingsUI(manager: manager)

    if manager.getProgressStats().completed == 0 {
      Terminal.clear()
      print(manager.welcomeMessage)
      print("\nPress ENTER to continue ", terminator: "")
      fflush(nil)
      let intro = RawTerminalInput()
      intro.enableRawMode()
      while true {
        let key = intro.waitForKey()
        if key == "\n" || key == "\r" { break }
      }
      intro.disableRawMode()
    }

    guard var currentExercise = manager.getCurrentExercise() else {
      Terminal.clear()
      Terminal.success("🎉 Congratulations! You've completed all Swiftlings exercises!")
      print("\n\(manager.finalMessage)")
      return
    }

    func pathFor(_ exercise: Exercise) -> String {
      URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent(exercise.filePath).path
    }

    var lastResult: ExerciseResult?
    var watcher = FileWatcher(path: pathFor(currentExercise))
    var showHint = false

    // Compile and run the current exercise, render the result, and start
    // watching its file from this point on.
    func runCurrentExercise(clearFirst: Bool = true) {
      if clearFirst {
        Terminal.clear()
      }

      let runner = ExerciseRunner(exercise: currentExercise)
      do {
        let result = try runner.run()
        lastResult = result

        // An exercise counts as done only once you move on from it (press `n`),
        // so the freebie intro does not bump the progress bar before you have
        // really started. See the `n` handler below.
        ui.renderWatchMode(currentExercise: currentExercise, result: result, showHint: showHint)
      } catch {
        Terminal.error("Failed to run exercise: \(error)")
      }

      watcher = FileWatcher(path: pathFor(currentExercise))
    }

    let rawInput = RawTerminalInput()
    rawInput.enableRawMode()
    defer { rawInput.disableRawMode() }

    runCurrentExercise()

    // One synchronous loop: react to a save, then to a keypress. readKey()
    // returns after a short timeout, so file changes are still noticed even
    // when no key is pressed.
    while true {
      if watcher.hasChanged() {
        runCurrentExercise()
        continue
      }

      guard let key = rawInput.readKey() else { continue }

      switch String(key).lowercased() {
        case "h":
          // Show the hint inline under the exercise, like Rustlings. Just redraw
          // the screen we already have, do not recompile, so there is no
          // "Compiling..." flash.
          showHint = true
          if let result = lastResult {
            ui.renderWatchMode(currentExercise: currentExercise, result: result, showHint: showHint)
          }

        case "l":
          Terminal.clear()
          let stats = manager.getProgressStats()
          let progressBar = ProgressBar(completed: stats.completed, total: stats.total, width: 80)

          Terminal.info("Exercise List")
          print("\n\(progressBar.formattedProgress())\n")

          let exercisesByDir = Dictionary(grouping: manager.getAllExercises()) { $0.dir }
          for (dir, exercises) in exercisesByDir.sorted(by: { $0.key < $1.key }) {
            print("\n[\(dir)]")
            for exercise in exercises {
              let status = manager.isCompleted(exercise.name) ? "✓" : "○"
              let current = exercise.name == currentExercise.name ? " ← current" : ""
              print("  \(status) \(exercise.name)\(current)")
            }
          }

          print("\nPress any key to continue...")
          _ = rawInput.waitForKey()
          runCurrentExercise()

        case "n":
          if let result = lastResult, result.isSuccess {
            manager.markCompleted(currentExercise)
            guard let next = manager.getNextPendingExercise() else {
              Terminal.clear()
              Terminal.success("All exercises completed! 🎉")
              print(manager.finalMessage)
              return
            }
            currentExercise = next
            manager.setCurrentExercise(next)
            showHint = false
            runCurrentExercise()
          } else {
            Terminal.warning("Complete the current exercise first")
            Thread.sleep(forTimeInterval: 1.5)
            runCurrentExercise()
          }

        case "c":
          Terminal.clear()
          print("Checking all exercises…")
          print("Color of exercise number: "
            + Terminal.colored("Checking", color: .blue) + " - "
            + Terminal.colored("Done", color: .green) + " - "
            + Terminal.colored("Pending", color: .red))
          print("Press any key to stop.")
          print("")

          let exercises = manager.getAllExercises()
          let total = exercises.count
          let numWidth = String(total).count
          let columns = max(1, (Terminal.width() + 1) / (numWidth + 1))
          let rows = (total + columns - 1) / columns

          var done = exercises.map { manager.isCompleted($0.name) }
          var checking: Int? = nil

          // Build the grid of exercise numbers, each colored by its state.
          func gridLines() -> [String] {
            (0..<rows).map { row in
              (0..<columns).compactMap { column -> String? in
                let index = row * columns + column
                guard index < total else { return nil }
                let label = String(format: "%\(numWidth)d", index + 1)
                let color: TerminalColor = index == checking ? .blue : (done[index] ? .green : .red)
                return Terminal.colored(label, color: color)
              }.joined(separator: " ")
            }
          }
          func drawGrid() { gridLines().forEach { print($0) } }
          func redrawGrid() {
            print("\u{001B}[\(rows)A", terminator: "")
            gridLines().forEach { print("\u{001B}[2K" + $0) }
          }

          drawGrid()

          var stopped = false
          for (index, exercise) in exercises.enumerated() {
            if rawInput.readKeyIfAvailable() != nil {
              stopped = true
              break
            }
            if done[index] { continue }
            checking = index
            redrawGrid()
            if let result = try? ExerciseRunner(exercise: exercise).run(quiet: true), result.isSuccess {
              done[index] = true
              manager.markCompleted(exercise)
            }
            checking = nil
          }
          checking = nil
          redrawGrid()

          print("")
          print(stopped ? "Stopped. Press any key to continue..." : "Press any key to continue...")
          _ = rawInput.waitForKey()

          if let newCurrent = manager.getCurrentExercise() {
            currentExercise = newCurrent
          }
          showHint = false
          runCurrentExercise()

        case "x":
          if manager.categoryFilter != nil {
            print("⚠️  Reset all DSA exercises? (y/n): ", terminator: "")
            fflush(nil)
            if String(rawInput.waitForKey()).lowercased() == "y" {
              Terminal.info("Resetting all DSA exercises...")
              manager.resetDSAProgress()
              Terminal.success("All DSA exercises reset!")
              Thread.sleep(forTimeInterval: 1)
              if let firstExercise = manager.getAllExercises().first {
                currentExercise = firstExercise
              }
            }
            runCurrentExercise()
          } else {
            Terminal.clear()
            print("Resetting will undo all your changes to the file \(currentExercise.filePath)")
            print("Reset (y/n)? ", terminator: "")
            fflush(nil)
            if String(rawInput.waitForKey()).lowercased() == "y" {
              do {
                try manager.resetExercise(currentExercise)
              } catch {
                Terminal.error("Failed to reset: \(error)")
                Thread.sleep(forTimeInterval: 1.5)
              }
            }
            showHint = false
            runCurrentExercise()
          }

        case "q":
          Terminal.clear()
          print("We hope you're enjoying learning Swift!")
          print("If you want to continue working on the exercises at a later point, you can simply run `swiftlings` again in this directory.")
          return

        default:
          break
      }
    }
  }
}
