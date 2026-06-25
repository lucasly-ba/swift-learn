import XCTest
import Foundation
@testable import Swiftlings

final class ExerciseTests: XCTestCase {
  func testExerciseInitialization() {
    let exercise = Exercise(
      name: "variables1",
      dir: "01_variables",
      hint: "This is a hint",
      dependencies: ["Foundation"]
    )

    XCTAssertTrue(exercise.name == "variables1")
    XCTAssertTrue(exercise.dir == "01_variables")
    XCTAssertTrue(exercise.hint == "This is a hint")
    XCTAssertTrue(exercise.dependencies == ["Foundation"])
    XCTAssertTrue(exercise.filePath == "Exercises/01_variables/variables1.swift")
  }

  func testExerciseWithoutDependencies() {
    let exercise = Exercise(
      name: "intro1",
      dir: "00_basics",
      hint: "Simple intro",
      dependencies: nil
    )

    XCTAssertTrue(exercise.dependencies == nil)
  }

  func testFilePathConstruction() {
    let testCases = [
      (name: "test1", dir: "00_basics", expected: "Exercises/00_basics/test1.swift"),
      (name: "functions1", dir: "02_functions", expected: "Exercises/02_functions/functions1.swift"),
      (name: "complex_name", dir: "deep/nested/dir", expected: "Exercises/deep/nested/dir/complex_name.swift"),
    ]

    for testCase in testCases {
      let exercise = Exercise(
        name: testCase.name,
        dir: testCase.dir,
        hint: "",
        dependencies: nil
      )
      XCTAssertTrue(exercise.filePath == testCase.expected)
    }
  }

  func testExerciseEquality() {
    let exercise1 = Exercise(
      name: "test",
      dir: "dir",
      hint: "hint",
      dependencies: ["A", "B"]
    )

    let exercise2 = Exercise(
      name: "test",
      dir: "dir",
      hint: "hint",
      dependencies: ["A", "B"]
    )

    let exercise3 = Exercise(
      name: "different",
      dir: "dir",
      hint: "hint",
      dependencies: ["A", "B"]
    )

    XCTAssertTrue(exercise1 == exercise2)
    XCTAssertTrue(exercise1 != exercise3)
  }

  func testExerciseCodable() throws {
    let original = Exercise(
      name: "codable_test",
      dir: "test_dir",
      hint: "Test hint with special chars: 🎯 \"quotes\" and 'apostrophes'",
      dependencies: ["Foundation", "UIKit"]
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(original)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Exercise.self, from: data)

    XCTAssertTrue(decoded == original)
    XCTAssertTrue(decoded.name == original.name)
    XCTAssertTrue(decoded.dir == original.dir)
    XCTAssertTrue(decoded.hint == original.hint)
    XCTAssertTrue(decoded.dependencies == original.dependencies)
  }
}
