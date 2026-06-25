import XCTest
import Foundation
@testable import Swiftlings

final class ExerciseCompilerTests: XCTestCase {

  class MockFileManager: FileManager {
    var fileExistsResponses: [String: Bool] = [:]

    override func fileExists(atPath path: String) -> Bool {
      return fileExistsResponses[path] ?? false
    }
  }

  func testCompilationResultProperties() {
    let success = CompilationResult.success(output: "Compilation successful")
    XCTAssertTrue(success.isSuccess == true)

    let failure = CompilationResult.failure(message: "Error: undefined symbol")
    XCTAssertTrue(failure.isSuccess == false)
  }

  func testSuccessfulCompilation() throws {
    let mockRunner = MockProcessRunner()
    let mockFileManager = MockFileManager()
    let compiler = ExerciseCompiler(
      processRunner: mockRunner,
      fileManager: mockFileManager
    )

    let exercise = Exercise(
      name: "test_exercise",
      dir: "test_dir",
      hint: "Test hint",
      dependencies: nil
    )

    let workDir = URL(fileURLWithPath: "/tmp/test")


    mockRunner.mockResults = [
      ProcessResult(exitCode: 0, stdout: "Compilation successful", stderr: ""),
    ]


    mockFileManager.fileExistsResponses["/tmp/test/Assert.swift"] = false

    let result = try compiler.compile(
      exercise: exercise,
      in: workDir,
      includeAssert: true
    )


    switch result {
      case .success(let output):
        XCTAssertTrue(output == "Compilation successful")
      case .failure:
        XCTFail("Expected success but got failure")
    }


    XCTAssertTrue(mockRunner.capturedCalls.count == 1)
    let call = mockRunner.capturedCalls[0]
    XCTAssertTrue(call.executable == "/usr/bin/swiftc")
    XCTAssertTrue(call.arguments == ["-o", "exercise", "main.swift", "test_exercise.swift"])
    XCTAssertTrue(call.directory?.path == "/tmp/test")
  }

  func testCompilationWithAssert() throws {
    let mockRunner = MockProcessRunner()
    let mockFileManager = MockFileManager()
    let compiler = ExerciseCompiler(
      processRunner: mockRunner,
      fileManager: mockFileManager
    )

    let exercise = Exercise(
      name: "assert_test",
      dir: "test_dir",
      hint: "Test hint",
      dependencies: nil
    )

    let workDir = URL(fileURLWithPath: "/tmp/test")


    mockRunner.mockResults = [
      ProcessResult(exitCode: 0, stdout: "Success", stderr: ""),
    ]


    mockFileManager.fileExistsResponses["/tmp/test/Assert.swift"] = true

    let result = try compiler.compile(
      exercise: exercise,
      in: workDir,
      includeAssert: true
    )

    XCTAssertTrue(result.isSuccess)


    let call = mockRunner.capturedCalls[0]
    XCTAssertTrue(call.arguments.contains("Assert.swift"))
    XCTAssertTrue(call.arguments == ["-o", "exercise", "main.swift", "assert_test.swift", "Assert.swift"])
  }

  func testCompilationWithoutAssertFlag() throws {
    let mockRunner = MockProcessRunner()
    let mockFileManager = MockFileManager()
    let compiler = ExerciseCompiler(
      processRunner: mockRunner,
      fileManager: mockFileManager
    )

    let exercise = Exercise(
      name: "no_assert",
      dir: "test_dir",
      hint: "Test hint",
      dependencies: nil
    )

    let workDir = URL(fileURLWithPath: "/tmp/test")

    mockRunner.mockResults = [
      ProcessResult(exitCode: 0, stdout: "Success", stderr: ""),
    ]


    mockFileManager.fileExistsResponses["/tmp/test/Assert.swift"] = true

    let result = try compiler.compile(
      exercise: exercise,
      in: workDir,
      includeAssert: false
    )

    XCTAssertTrue(result.isSuccess)


    let call = mockRunner.capturedCalls[0]
    XCTAssertTrue(!call.arguments.contains("Assert.swift"))
  }

  func testCompilationFailure() throws {
    let mockRunner = MockProcessRunner()
    let mockFileManager = MockFileManager()
    let compiler = ExerciseCompiler(
      processRunner: mockRunner,
      fileManager: mockFileManager
    )

    let exercise = Exercise(
      name: "failing_exercise",
      dir: "test_dir",
      hint: "Test hint",
      dependencies: nil
    )

    let workDir = URL(fileURLWithPath: "/tmp/test")


    mockRunner.mockResults = [
      ProcessResult(
        exitCode: 1,
        stdout: "",
        stderr: "error: use of unresolved identifier 'foo'"
      ),
    ]

    let result = try compiler.compile(
      exercise: exercise,
      in: workDir,
      includeAssert: false
    )


    switch result {
      case .success:
        XCTFail("Expected failure but got success")
      case .failure(let message):
        XCTAssertTrue(message == "error: use of unresolved identifier 'foo'")
    }
  }

  func testCompilationFailureWithStdout() throws {
    let mockRunner = MockProcessRunner()
    let compiler = ExerciseCompiler(
      processRunner: mockRunner,
      fileManager: MockFileManager()
    )

    let exercise = Exercise(
      name: "stdout_error",
      dir: "test_dir",
      hint: "Test hint",
      dependencies: nil
    )

    mockRunner.mockResults = [
      ProcessResult(
        exitCode: 1,
        stdout: "Error output in stdout",
        stderr: ""
      ),
    ]

    let result = try compiler.compile(
      exercise: exercise,
      in: URL(fileURLWithPath: "/tmp"),
      includeAssert: false
    )

    switch result {
      case .success:
        XCTFail("Expected failure")
      case .failure(let message):
        XCTAssertTrue(message == "Error output in stdout")
    }
  }

  func testCompilationWithDifferentExerciseNames() throws {
    let mockRunner = MockProcessRunner()
    let compiler = ExerciseCompiler(
      processRunner: mockRunner,
      fileManager: MockFileManager()
    )

    let exerciseNames = ["intro1", "variables_test", "complex-name", "test123"]

    for name in exerciseNames {
      mockRunner.reset()
      mockRunner.mockResults = [
        ProcessResult(exitCode: 0, stdout: "Success", stderr: ""),
      ]

      let exercise = Exercise(
        name: name,
        dir: "dir",
        hint: "hint",
        dependencies: nil
      )

      _ = try compiler.compile(
        exercise: exercise,
        in: URL(fileURLWithPath: "/tmp"),
        includeAssert: false
      )

      let call = mockRunner.capturedCalls[0]
      XCTAssertTrue(call.arguments.contains("\(name).swift"))
    }
  }
}
