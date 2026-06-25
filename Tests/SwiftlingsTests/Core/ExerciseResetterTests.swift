import XCTest
import Foundation
@testable import Swiftlings

final class ExerciseResetterTests: XCTestCase {
  func testResetErrorDescriptions() {
    let gitError = ResetError.gitResetFailed("fatal: pathspec 'file.swift' did not match any files")
    XCTAssertTrue(gitError.errorDescription == "Failed to reset exercise: fatal: pathspec 'file.swift' did not match any files")

    let multipleErrors = ResetError.multipleErrors([
      "Failed to reset intro1: File not found",
      "Failed to reset variables1: Permission denied",
    ])
    XCTAssertTrue(multipleErrors.errorDescription == "Multiple reset errors:\nFailed to reset intro1: File not found\nFailed to reset variables1: Permission denied")
  }

  func testSuccessfulReset() throws {
    let mockRunner = MockProcessRunner()
    let resetter = ExerciseResetter(processRunner: mockRunner)

    let exercise = Exercise(
      name: "test_exercise",
      dir: "test_dir",
      hint: "Test hint",
      dependencies: nil
    )


    mockRunner.mockResults = [
      ProcessResult(exitCode: 0, stdout: "", stderr: ""),
    ]

    try resetter.resetExercise(exercise)


    XCTAssertTrue(mockRunner.capturedCalls.count == 1)
    let call = mockRunner.capturedCalls[0]
    XCTAssertTrue(call.executable == "/usr/bin/git")
    XCTAssertTrue(call.arguments == ["checkout", "HEAD", "--", "Exercises/test_dir/test_exercise.swift"])
    XCTAssertTrue(call.directory == nil)
  }

  func testGitResetFailure() throws {
    let mockRunner = MockProcessRunner()
    let resetter = ExerciseResetter(processRunner: mockRunner)

    let exercise = Exercise(
      name: "failing_exercise",
      dir: "test_dir",
      hint: "Test hint",
      dependencies: nil
    )


    mockRunner.mockResults = [
      ProcessResult(
        exitCode: 1,
        stdout: "",
        stderr: "error: pathspec 'Exercises/test_dir/failing_exercise.swift' did not match any file(s) known to git"
      ),
    ]

    XCTAssertThrowsError(try resetter.resetExercise(exercise))
  }

  func testResetMultipleExercisesSuccess() throws {
    let mockRunner = MockProcessRunner()
    let resetter = ExerciseResetter(processRunner: mockRunner)

    let exercises = [
      Exercise(name: "ex1", dir: "dir1", hint: "hint1", dependencies: nil),
      Exercise(name: "ex2", dir: "dir2", hint: "hint2", dependencies: nil),
      Exercise(name: "ex3", dir: "dir3", hint: "hint3", dependencies: nil),
    ]


    mockRunner.mockResults = [
      ProcessResult(exitCode: 0, stdout: "", stderr: ""),
      ProcessResult(exitCode: 0, stdout: "", stderr: ""),
      ProcessResult(exitCode: 0, stdout: "", stderr: ""),
    ]

    try resetter.resetExercises(exercises)


    XCTAssertTrue(mockRunner.capturedCalls.count == 3)
    XCTAssertTrue(mockRunner.capturedCalls[0].arguments.contains("Exercises/dir1/ex1.swift"))
    XCTAssertTrue(mockRunner.capturedCalls[1].arguments.contains("Exercises/dir2/ex2.swift"))
    XCTAssertTrue(mockRunner.capturedCalls[2].arguments.contains("Exercises/dir3/ex3.swift"))
  }

  func testResetMultipleExercisesWithFailures() throws {
    let mockRunner = MockProcessRunner()
    let resetter = ExerciseResetter(processRunner: mockRunner)

    let exercises = [
      Exercise(name: "ex1", dir: "dir1", hint: "hint1", dependencies: nil),
      Exercise(name: "ex2", dir: "dir2", hint: "hint2", dependencies: nil),
      Exercise(name: "ex3", dir: "dir3", hint: "hint3", dependencies: nil),
    ]


    mockRunner.mockResults = [
      ProcessResult(exitCode: 0, stdout: "", stderr: ""),
      ProcessResult(exitCode: 1, stdout: "", stderr: "Permission denied"),
      ProcessResult(exitCode: 0, stdout: "", stderr: ""),
    ]

    XCTAssertThrowsError(try resetter.resetExercises(exercises))


    XCTAssertTrue(mockRunner.capturedCalls.count == 3)
  }

  func testResetEmptyList() throws {
    let mockRunner = MockProcessRunner()
    let resetter = ExerciseResetter(processRunner: mockRunner)


    try resetter.resetExercises([])


    XCTAssertTrue(mockRunner.capturedCalls.isEmpty)
  }

  func testResetWithDifferentPaths() throws {
    let mockRunner = MockProcessRunner()
    let resetter = ExerciseResetter(processRunner: mockRunner)

    let testCases = [
      (name: "simple", dir: "basics", expected: "Exercises/basics/simple.swift"),
      (name: "complex_name", dir: "advanced/nested", expected: "Exercises/advanced/nested/complex_name.swift"),
      (name: "test-123", dir: "00_intro", expected: "Exercises/00_intro/test-123.swift"),
    ]

    for testCase in testCases {
      mockRunner.reset()
      mockRunner.mockResults = [
        ProcessResult(exitCode: 0, stdout: "", stderr: ""),
      ]

      let exercise = Exercise(
        name: testCase.name,
        dir: testCase.dir,
        hint: "hint",
        dependencies: nil
      )

      try resetter.resetExercise(exercise)

      let call = mockRunner.capturedCalls[0]
      XCTAssertTrue(call.arguments.last == testCase.expected)
    }
  }

  func testMultipleErrorsFormatting() throws {
    let mockRunner = MockProcessRunner()
    let resetter = ExerciseResetter(processRunner: mockRunner)

    let exercises = [
      Exercise(name: "ex1", dir: "dir1", hint: "hint1", dependencies: nil),
      Exercise(name: "ex2", dir: "dir2", hint: "hint2", dependencies: nil),
      Exercise(name: "ex3", dir: "dir3", hint: "hint3", dependencies: nil),
    ]


    mockRunner.mockResults = [
      ProcessResult(exitCode: 1, stdout: "", stderr: "Error 1"),
      ProcessResult(exitCode: 1, stdout: "", stderr: "Error 2"),
      ProcessResult(exitCode: 1, stdout: "", stderr: "Error 3"),
    ]

    XCTAssertThrowsError(try resetter.resetExercises(exercises))
  }
}
