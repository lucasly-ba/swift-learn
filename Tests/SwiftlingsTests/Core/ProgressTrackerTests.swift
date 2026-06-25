import XCTest
import Foundation
@testable import Swiftlings

final class ProgressTrackerTests: XCTestCase {

  func withTemporaryDirectory(_ test: (URL) throws -> Void) throws {
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    let originalDir = FileManager.default.currentDirectoryPath
    FileManager.default.changeCurrentDirectoryPath(tempDir.path)

    defer {
      FileManager.default.changeCurrentDirectoryPath(originalDir)
      try? FileManager.default.removeItem(at: tempDir)
    }

    try test(tempDir)
  }

  func testInitializationWithNoState() throws {
    try withTemporaryDirectory { _ in
      let tracker = ProgressTracker()

      XCTAssertTrue(tracker.getCurrentExercise() == nil)
      XCTAssertTrue(!tracker.isCompleted("any_exercise"))

      let stats = tracker.getStats(totalExercises: 10)
      XCTAssertTrue(stats.completed == 0)
      XCTAssertTrue(stats.percentage == 0.0)
    }
  }

  func testMarkCompleted() throws {
    try withTemporaryDirectory { _ in
      let tracker = ProgressTracker()

      XCTAssertTrue(!tracker.isCompleted("variables1"))

      tracker.markCompleted("variables1")

      XCTAssertTrue(tracker.isCompleted("variables1"))
      XCTAssertTrue(!tracker.isCompleted("variables2"))
    }
  }

  func testCurrentExercise() throws {
    try withTemporaryDirectory { _ in
      let tracker = ProgressTracker()

      XCTAssertTrue(tracker.getCurrentExercise() == nil)

      tracker.setCurrentExercise("functions1")
      XCTAssertTrue(tracker.getCurrentExercise() == "functions1")

      tracker.setCurrentExercise("functions2")
      XCTAssertTrue(tracker.getCurrentExercise() == "functions2")
    }
  }

  func testProgressStatistics() throws {
    try withTemporaryDirectory { _ in
      let tracker = ProgressTracker()


      var stats = tracker.getStats(totalExercises: 10)
      XCTAssertTrue(stats.completed == 0)
      XCTAssertTrue(stats.percentage == 0.0)


      tracker.markCompleted("ex1")
      tracker.markCompleted("ex2")
      tracker.markCompleted("ex3")

      stats = tracker.getStats(totalExercises: 10)
      XCTAssertTrue(stats.completed == 3)
      XCTAssertTrue(stats.percentage == 30.0)


      for i in 4 ... 10 {
        tracker.markCompleted("ex\(i)")
      }

      stats = tracker.getStats(totalExercises: 10)
      XCTAssertTrue(stats.completed == 10)
      XCTAssertTrue(stats.percentage == 100.0)


      stats = tracker.getStats(totalExercises: 0)
      XCTAssertTrue(stats.completed == 10)
      XCTAssertTrue(stats.percentage == 0.0)
    }
  }

  func testResetProgress() throws {
    try withTemporaryDirectory { _ in
      let tracker = ProgressTracker()


      tracker.markCompleted("ex1")
      tracker.markCompleted("ex2")
      tracker.setCurrentExercise("ex3")

      XCTAssertTrue(tracker.isCompleted("ex1"))
      XCTAssertTrue(tracker.isCompleted("ex2"))
      XCTAssertTrue(tracker.getCurrentExercise() == "ex3")


      tracker.resetProgress()

      XCTAssertTrue(!tracker.isCompleted("ex1"))
      XCTAssertTrue(!tracker.isCompleted("ex2"))
      XCTAssertTrue(tracker.getCurrentExercise() == nil)

      let stats = tracker.getStats(totalExercises: 10)
      XCTAssertTrue(stats.completed == 0)
      XCTAssertTrue(stats.percentage == 0.0)
    }
  }

  func testStatePersistence() throws {
    try withTemporaryDirectory { tempDir in

      let stateFile = tempDir.appendingPathComponent(".swiftlings-state.json")


      var state1 = ProgressTracker.ProgressState()
      state1.completedExercises.insert("persistent1")
      state1.completedExercises.insert("persistent2")
      state1.currentExercise = "persistent3"

      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      let data = try encoder.encode(state1)
      try data.write(to: stateFile)





      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let loadedState = try decoder.decode(ProgressTracker.ProgressState.self, from: data)

      XCTAssertTrue(loadedState.completedExercises.contains("persistent1"))
      XCTAssertTrue(loadedState.completedExercises.contains("persistent2"))
      XCTAssertTrue(loadedState.currentExercise == "persistent3")
    }
  }

  func testMultipleCompletions() throws {
    try withTemporaryDirectory { _ in
      let tracker = ProgressTracker()
      let exercises = ["intro1", "variables1", "functions1", "arrays1", "structs1"]

      for exercise in exercises {
        XCTAssertTrue(!tracker.isCompleted(exercise))
        tracker.markCompleted(exercise)
        XCTAssertTrue(tracker.isCompleted(exercise))
      }

      let stats = tracker.getStats(totalExercises: 10)
      XCTAssertTrue(stats.completed == 5)
      XCTAssertTrue(stats.percentage == 50.0)


      tracker.markCompleted("intro1")
      tracker.markCompleted("intro1")

      let statsAfter = tracker.getStats(totalExercises: 10)
      XCTAssertTrue(statsAfter.completed == 5)
    }
  }

  func testStateFileFormat() throws {


    var state = ProgressTracker.ProgressState()
    state.completedExercises.insert("test1")
    state.currentExercise = "test2"
    state.lastUpdated = Date()

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(state)

    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    XCTAssertTrue(json != nil)
    XCTAssertTrue(json?["currentExercise"] as? String == "test2")
    XCTAssertTrue((json?["completedExercises"] as? [String])?.contains("test1") == true)
    XCTAssertTrue(json?["lastUpdated"] != nil)
  }
}
