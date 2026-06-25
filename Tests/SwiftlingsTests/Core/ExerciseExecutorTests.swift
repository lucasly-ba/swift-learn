import XCTest
import Foundation
@testable import Swiftlings

final class ExerciseExecutorTests: XCTestCase {
  func testSuccessfulExecutionWithoutTests() throws {
    let mockRunner = MockProcessRunner()
    let executor = ExerciseExecutor(processRunner: mockRunner)

    let executablePath = URL(fileURLWithPath: "/tmp/test/exercise")


    mockRunner.mockResults = [
      ProcessResult(exitCode: 0, stdout: "Hello, World!", stderr: ""),
    ]

    let result = try executor.execute(
      executablePath: executablePath,
      usesTests: false
    )


    switch result {
      case .success(let output):
        XCTAssertTrue(output == "Hello, World!")
      case .testFailure:
        XCTFail("Expected success but got test failure")
    }


    XCTAssertTrue(mockRunner.capturedCalls.count == 1)
    let call = mockRunner.capturedCalls[0]
    XCTAssertTrue(call.executable == "/tmp/test/exercise")
    XCTAssertTrue(call.arguments.isEmpty)
    XCTAssertTrue(call.directory?.path == "/tmp/test")
  }

  func testSuccessfulExecutionWithTests() throws {
    let mockRunner = MockProcessRunner()
    let executor = ExerciseExecutor(processRunner: mockRunner)

    let executablePath = URL(fileURLWithPath: "/tmp/test/exercise")


    mockRunner.mockResults = [
      ProcessResult(exitCode: 0, stdout: "All tests passed!", stderr: ""),
    ]

    let result = try executor.execute(
      executablePath: executablePath,
      usesTests: true
    )

    switch result {
      case .success(let output):
        XCTAssertTrue(output == "All tests passed!")
      case .testFailure:
        XCTFail("Expected success but got test failure")
    }
  }

  func testExecutionWithTestFailure() throws {
    let mockRunner = MockProcessRunner()
    let executor = ExerciseExecutor(processRunner: mockRunner)

    let executablePath = URL(fileURLWithPath: "/tmp/test/exercise")


    mockRunner.mockResults = [
      ProcessResult(
        exitCode: 1,
        stdout: "Test 1: Passed\nTest 2: Failed",
        stderr: "Assertion failed"
      ),
    ]

    let result = try executor.execute(
      executablePath: executablePath,
      usesTests: true
    )

    switch result {
      case .success:
        XCTFail("Expected test failure but got success")
      case .testFailure(let message):
        XCTAssertTrue(message == "Test 1: Passed\nTest 2: Failed\nAssertion failed")
    }
  }

  func testExecutionFailureWithoutTests() throws {
    let mockRunner = MockProcessRunner()
    let executor = ExerciseExecutor(processRunner: mockRunner)

    let executablePath = URL(fileURLWithPath: "/tmp/test/exercise")


    mockRunner.mockResults = [
      ProcessResult(
        exitCode: 1,
        stdout: "",
        stderr: "Segmentation fault"
      ),
    ]

    let result = try executor.execute(
      executablePath: executablePath,
      usesTests: false
    )

    switch result {
      case .success:
        XCTFail("Expected failure but got success")
      case .testFailure(let message):
        XCTAssertTrue(message == "Segmentation fault")
    }
  }

  func testExecutionFailureWithoutStderr() throws {
    let mockRunner = MockProcessRunner()
    let executor = ExerciseExecutor(processRunner: mockRunner)

    let executablePath = URL(fileURLWithPath: "/tmp/test/exercise")


    mockRunner.mockResults = [
      ProcessResult(
        exitCode: 42,
        stdout: "",
        stderr: ""
      ),
    ]

    let result = try executor.execute(
      executablePath: executablePath,
      usesTests: false
    )

    switch result {
      case .success:
        XCTFail("Expected failure but got success")
      case .testFailure(let message):
        XCTAssertTrue(message == "Exercise failed with exit code 42")
    }
  }

  func testExecutionWithDifferentPaths() throws {
    let mockRunner = MockProcessRunner()
    let executor = ExerciseExecutor(processRunner: mockRunner)

    let testPaths = [
      "/tmp/exercise",
      "/usr/local/bin/test",
      "/home/user/swiftlings/exercise",
      "/tmp/dir with spaces/exercise",
    ]

    for path in testPaths {
      mockRunner.reset()
      mockRunner.mockResults = [
        ProcessResult(exitCode: 0, stdout: "Success", stderr: ""),
      ]

      let url = URL(fileURLWithPath: path)
      _ = try executor.execute(executablePath: url, usesTests: false)

      let call = mockRunner.capturedCalls[0]
      XCTAssertTrue(call.executable == path)
      XCTAssertTrue(call.directory?.path == url.deletingLastPathComponent().path)
    }
  }

  func testExecutionWithEmptyStdoutTestMode() throws {
    let mockRunner = MockProcessRunner()
    let executor = ExerciseExecutor(processRunner: mockRunner)

    let executablePath = URL(fileURLWithPath: "/tmp/test/exercise")


    mockRunner.mockResults = [
      ProcessResult(
        exitCode: 1,
        stdout: "",
        stderr: "Test assertion failed at line 10"
      ),
    ]

    let result = try executor.execute(
      executablePath: executablePath,
      usesTests: true
    )

    switch result {
      case .success:
        XCTFail("Expected test failure")
      case .testFailure(let message):
        XCTAssertTrue(message == "\nTest assertion failed at line 10")
    }
  }

  func testExecutionWithCombinedOutput() throws {
    let mockRunner = MockProcessRunner()
    let executor = ExerciseExecutor(processRunner: mockRunner)

    let executablePath = URL(fileURLWithPath: "/tmp/test/exercise")


    mockRunner.mockResults = [
      ProcessResult(
        exitCode: 1,
        stdout: "Running tests...\nTest 1: OK",
        stderr: "Fatal error: Test 2 failed"
      ),
    ]

    let result = try executor.execute(
      executablePath: executablePath,
      usesTests: true
    )

    switch result {
      case .success:
        XCTFail("Expected test failure")
      case .testFailure(let message):
        XCTAssertTrue(message == "Running tests...\nTest 1: OK\nFatal error: Test 2 failed")
    }
  }
}
