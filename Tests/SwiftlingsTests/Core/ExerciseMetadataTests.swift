import XCTest
import Foundation
@testable import Swiftlings

final class ExerciseMetadataTests: XCTestCase {
  func testExerciseMetadataInitialization() {
    let exercises = [
      Exercise(name: "intro1", dir: "00_basics", hint: "Intro hint", dependencies: nil),
      Exercise(name: "variables1", dir: "01_variables", hint: "Variables hint", dependencies: ["Foundation"]),
    ]

    let metadata = ExerciseMetadata(
      formatVersion: 1,
      welcomeMessage: "Welcome to Swiftlings!",
      finalMessage: "Congratulations!",
      exercises: exercises
    )

    XCTAssertTrue(metadata.formatVersion == 1)
    XCTAssertTrue(metadata.welcomeMessage == "Welcome to Swiftlings!")
    XCTAssertTrue(metadata.finalMessage == "Congratulations!")
    XCTAssertTrue(metadata.exercises.count == 2)
    XCTAssertTrue(metadata.exercises[0].name == "intro1")
    XCTAssertTrue(metadata.exercises[1].name == "variables1")
  }

  func testExerciseMetadataCodable() throws {
    let exercises = [
      Exercise(name: "test1", dir: "test", hint: "Hint 1", dependencies: nil),
      Exercise(name: "test2", dir: "test", hint: "Hint 2", dependencies: ["Foundation", "UIKit"]),
    ]

    let original = ExerciseMetadata(
      formatVersion: 2,
      welcomeMessage: "Welcome message with special chars: 🎯 \"quotes\"",
      finalMessage: "Final message with newline\nand more text",
      exercises: exercises
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(original)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ExerciseMetadata.self, from: data)

    XCTAssertTrue(decoded.formatVersion == original.formatVersion)
    XCTAssertTrue(decoded.welcomeMessage == original.welcomeMessage)
    XCTAssertTrue(decoded.finalMessage == original.finalMessage)
    XCTAssertTrue(decoded.exercises.count == original.exercises.count)
    XCTAssertTrue(decoded.exercises == original.exercises)
  }

  func testJSONKeyMapping() throws {
    let jsonString = """
      {
        "format_version": 3,
        "welcome_message": "Test welcome",
        "final_message": "Test final",
        "exercises": [
          {
            "name": "exercise1",
            "dir": "dir1",
            "hint": "hint1"
          }
        ]
      }
      """

    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    let metadata = try decoder.decode(ExerciseMetadata.self, from: data)

    XCTAssertTrue(metadata.formatVersion == 3)
    XCTAssertTrue(metadata.welcomeMessage == "Test welcome")
    XCTAssertTrue(metadata.finalMessage == "Test final")
    XCTAssertTrue(metadata.exercises.count == 1)
  }

  func testLoadFromFile() throws {

    let tempDir = FileManager.default.temporaryDirectory
    let tempFile = tempDir.appendingPathComponent("test_info.json")

    let testMetadata = ExerciseMetadata(
      formatVersion: 1,
      welcomeMessage: "Welcome from file",
      finalMessage: "Final from file",
      exercises: [
        Exercise(name: "file_test", dir: "test_dir", hint: "File test hint", dependencies: nil),
      ]
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(testMetadata)
    try data.write(to: tempFile)

    defer {
      try? FileManager.default.removeItem(at: tempFile)
    }


    let loaded = try ExerciseMetadata.load(from: tempFile.path)

    XCTAssertTrue(loaded.formatVersion == 1)
    XCTAssertTrue(loaded.welcomeMessage == "Welcome from file")
    XCTAssertTrue(loaded.finalMessage == "Final from file")
    XCTAssertTrue(loaded.exercises.count == 1)
    XCTAssertTrue(loaded.exercises[0].name == "file_test")
  }

  func testLoadFromMissingFile() {
    XCTAssertThrowsError(try ExerciseMetadata.load(from: "/nonexistent/path/info.json"))
  }

  func testEmptyExercises() throws {
    let metadata = ExerciseMetadata(
      formatVersion: 1,
      welcomeMessage: "Welcome",
      finalMessage: "Final",
      exercises: []
    )

    XCTAssertTrue(metadata.exercises.isEmpty)


    let encoder = JSONEncoder()
    let data = try encoder.encode(metadata)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ExerciseMetadata.self, from: data)

    XCTAssertTrue(decoded.exercises.isEmpty)
  }

  func testMalformedJSON() {
    let malformedJSON = """
      {
        "format_version": "not a number",
        "welcome_message": "Test",
        "final_message": "Test",
        "exercises": []
      }
      """

    let data = malformedJSON.data(using: .utf8)!
    let decoder = JSONDecoder()

    XCTAssertThrowsError(try decoder.decode(ExerciseMetadata.self, from: data))
  }
}
