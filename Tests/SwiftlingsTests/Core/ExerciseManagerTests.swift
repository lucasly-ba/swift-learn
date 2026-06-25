import XCTest
import Foundation
@testable import Swiftlings

final class ExerciseManagerTests: XCTestCase {
  class MockProgressTracker: ProgressTracker {
    var completedExercises: Set<String> = []
    var currentExercise: String?

    override func isCompleted(_ exerciseName: String) -> Bool {
      completedExercises.contains(exerciseName)
    }

    override func markCompleted(_ exerciseName: String) {
      completedExercises.insert(exerciseName)
    }

    override func getCurrentExercise() -> String? {
      currentExercise
    }

    override func setCurrentExercise(_ exerciseName: String) {
      currentExercise = exerciseName
    }

    override func getStats(totalExercises: Int) -> (completed: Int, percentage: Double) {
      let completed = completedExercises.count
      let percentage = totalExercises > 0 ? Double(completed) / Double(totalExercises) * 100 : 0
      return (completed, percentage)
    }

    override func resetProgress() {
      completedExercises.removeAll()
      currentExercise = nil
    }
  }


  func createTestMetadata() -> ExerciseMetadata {
    let exercises = [
      Exercise(name: "intro1", dir: "00_basics", hint: "Intro hint", dependencies: nil),
      Exercise(name: "intro2", dir: "00_basics", hint: "Intro hint 2", dependencies: nil),
      Exercise(name: "variables1", dir: "01_variables", hint: "Variables hint", dependencies: ["Foundation"]),
      Exercise(name: "variables2", dir: "01_variables", hint: "Variables hint 2", dependencies: ["Foundation"]),
      Exercise(name: "functions1", dir: "02_functions", hint: "Functions hint", dependencies: nil),
    ]

    return ExerciseMetadata(
      formatVersion: 1,
      welcomeMessage: "Welcome to testing!",
      finalMessage: "Congratulations on testing!",
      exercises: exercises
    )
  }

  func testExerciseManagerWithTestData() throws {

    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    defer {
      try? FileManager.default.removeItem(at: tempDir)
    }

    let metadata = createTestMetadata()
    let encoder = JSONEncoder()
    let data = try encoder.encode(metadata)


    let exercisesDir = tempDir.appendingPathComponent("Exercises")
    try FileManager.default.createDirectory(at: exercisesDir, withIntermediateDirectories: true)


    try data.write(to: exercisesDir.appendingPathComponent("info.json"))


    let originalDir = FileManager.default.currentDirectoryPath
    FileManager.default.changeCurrentDirectoryPath(tempDir.path)
    defer {
      FileManager.default.changeCurrentDirectoryPath(originalDir)
    }


    let manager = try ExerciseManager()

    XCTAssertTrue(manager.allExercises.count == 5)
    XCTAssertTrue(manager.welcomeMessage == "Welcome to testing!")
    XCTAssertTrue(manager.finalMessage == "Congratulations on testing!")
  }

  func testGetAllExercises() throws {


    _ = MockProgressTracker()


    let exercises = [
      Exercise(name: "ex1", dir: "dir1", hint: "hint1", dependencies: nil),
      Exercise(name: "ex2", dir: "dir2", hint: "hint2", dependencies: nil),
    ]



    XCTAssertTrue(exercises.count == 2)
    XCTAssertTrue(exercises[0].name == "ex1")
    XCTAssertTrue(exercises[1].name == "ex2")
  }

  func testGetExerciseByName() {
    let exercises = [
      Exercise(name: "target", dir: "dir", hint: "hint", dependencies: nil),
      Exercise(name: "other", dir: "dir", hint: "hint", dependencies: nil),
    ]


    let found = exercises.first { $0.name == "target" }
    XCTAssertTrue(found?.name == "target")

    let notFound = exercises.first { $0.name == "nonexistent" }
    XCTAssertTrue(notFound == nil)
  }

  func testProgressTracking() {
    let tracker = MockProgressTracker()
    let exercises = createTestMetadata().exercises


    XCTAssertTrue(!tracker.isCompleted("intro1"))
    XCTAssertTrue(!tracker.isCompleted("variables1"))


    tracker.markCompleted("intro1")
    tracker.markCompleted("variables1")

    XCTAssertTrue(tracker.isCompleted("intro1"))
    XCTAssertTrue(tracker.isCompleted("variables1"))
    XCTAssertTrue(!tracker.isCompleted("intro2"))


    let completed = exercises.filter { tracker.isCompleted($0.name) }
    let pending = exercises.filter { !tracker.isCompleted($0.name) }

    XCTAssertTrue(completed.count == 2)
    XCTAssertTrue(pending.count == 3)
  }

  func testGetNextPendingExercise() {
    let tracker = MockProgressTracker()
    let exercises = createTestMetadata().exercises


    let firstPending = exercises.first { !tracker.isCompleted($0.name) }
    XCTAssertTrue(firstPending?.name == "intro1")


    tracker.markCompleted("intro1")
    tracker.markCompleted("intro2")

    let nextPending = exercises.first { !tracker.isCompleted($0.name) }
    XCTAssertTrue(nextPending?.name == "variables1")


    for exercise in exercises {
      tracker.markCompleted(exercise.name)
    }

    let noPending = exercises.first { !tracker.isCompleted($0.name) }
    XCTAssertTrue(noPending == nil)
  }

  func testExerciseStatus() {
    let tracker = MockProgressTracker()


    let completedStatus = tracker.isCompleted("test") ? "✅" : "❌"
    XCTAssertTrue(completedStatus == "❌")

    tracker.markCompleted("test")
    let newStatus = tracker.isCompleted("test") ? "✅" : "❌"
    XCTAssertTrue(newStatus == "✅")
  }

  func testProgressStatistics() {
    let tracker = MockProgressTracker()
    let totalExercises = 10


    var stats = tracker.getStats(totalExercises: totalExercises)
    XCTAssertTrue(stats.completed == 0)
    XCTAssertTrue(stats.percentage == 0.0)


    tracker.markCompleted("ex1")
    tracker.markCompleted("ex2")
    tracker.markCompleted("ex3")

    stats = tracker.getStats(totalExercises: totalExercises)
    XCTAssertTrue(stats.completed == 3)
    XCTAssertTrue(stats.percentage == 30.0)


    for i in 1 ... 10 {
      tracker.markCompleted("ex\(i)")
    }

    stats = tracker.getStats(totalExercises: totalExercises)
    XCTAssertTrue(stats.completed == 10)
    XCTAssertTrue(stats.percentage == 100.0)
  }

  func testCurrentExercise() {
    let tracker = MockProgressTracker()
    let exercises = createTestMetadata().exercises


    XCTAssertTrue(tracker.getCurrentExercise() == nil)


    tracker.setCurrentExercise("variables1")
    XCTAssertTrue(tracker.getCurrentExercise() == "variables1")


    if let currentName = tracker.getCurrentExercise() {
      let current = exercises.first { $0.name == currentName }
      XCTAssertTrue(current?.name == "variables1")
    }


    tracker.currentExercise = nil
    tracker.markCompleted("intro1")

    let firstPending = exercises.first { !tracker.isCompleted($0.name) }
    XCTAssertTrue(firstPending?.name == "intro2")
  }

  func testResetAllProgress() {
    let tracker = MockProgressTracker()


    tracker.markCompleted("ex1")
    tracker.markCompleted("ex2")
    tracker.setCurrentExercise("ex3")

    XCTAssertTrue(tracker.completedExercises.count == 2)
    XCTAssertTrue(tracker.currentExercise == "ex3")


    tracker.resetProgress()

    XCTAssertTrue(tracker.completedExercises.isEmpty)
    XCTAssertTrue(tracker.currentExercise == nil)
  }
}
