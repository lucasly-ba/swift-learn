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
    var finished = false

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

        switch result {
          case .success:
            manager.markCompleted(currentExercise)
            ui.renderWatchMode(currentExercise: currentExercise, result: result, showError: false)

            if manager.getNextPendingExercise() == nil {
              print("\n")
              Terminal.success("🎉 All exercises completed!")
              print(manager.finalMessage)
              finished = true
            }

          case .compilationError, .testFailure:
            ui.renderWatchMode(currentExercise: currentExercise, result: result, showError: true)
        }
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
    while !finished {
      if watcher.hasChanged() {
        runCurrentExercise()
        continue
      }

      guard let key = rawInput.readKey() else { continue }

      switch String(key).lowercased() {
        case "h":
          Terminal.clear()
          Terminal.info("Hint for \(currentExercise.name):")
          print("\n\(currentExercise.hint)\n")
          if let doc = currentExercise.doc {
            print("📖 Read more: \(doc)\n")
          }
          print("Press any key to continue...")
          _ = rawInput.waitForKey()
          runCurrentExercise()

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
            guard let next = manager.getNextPendingExercise() else {
              Terminal.success("All exercises completed! 🎉")
              print(manager.finalMessage)
              return
            }
            currentExercise = next
            manager.setCurrentExercise(next)
            Terminal.info("Moving to next exercise...")
            runCurrentExercise()
          } else {
            Terminal.warning("Complete the current exercise first")
            Thread.sleep(forTimeInterval: 1.5)
            runCurrentExercise()
          }

        case "c":
          Terminal.clear()
          Terminal.info("🔍 Checking all exercises...")
          print("")

          var failed = 0
          for exercise in manager.getPendingExercises() {
            let runner = ExerciseRunner(exercise: exercise)
            do {
              let result = try runner.run()
              switch result {
                case .success:
                  print("✅ \(exercise.name)")
                  manager.markCompleted(exercise)
                case .compilationError:
                  print("❌ \(exercise.name) - compilation error")
                  failed += 1
                case .testFailure:
                  print("❌ \(exercise.name) - test failure")
                  failed += 1
              }
            } catch {
              print("❌ \(exercise.name) - error: \(error)")
              failed += 1
            }
          }

          print("\nSummary: \(failed) exercises need work")
          print("Press any key to continue...")
          _ = rawInput.waitForKey()

          if let newCurrent = manager.getCurrentExercise() {
            currentExercise = newCurrent
          }
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
            Terminal.info("Resetting \(currentExercise.name)...")
            do {
              try manager.resetExercise(currentExercise)
              Terminal.success("Exercise reset!")
            } catch {
              Terminal.error("Failed to reset: \(error)")
            }
            Thread.sleep(forTimeInterval: 1)
            runCurrentExercise()
          }

        case "q":
          return

        default:
          break
      }
    }
  }
}
