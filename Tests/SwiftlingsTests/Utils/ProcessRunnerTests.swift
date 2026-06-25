import XCTest
import Foundation
@testable import Swiftlings

final class ProcessRunnerTests: XCTestCase {
  func testProcessResultProperties() {
    let successResult = ProcessResult(
      exitCode: 0,
      stdout: "Success output",
      stderr: ""
    )
    XCTAssertTrue(successResult.isSuccess == true)
    XCTAssertTrue(successResult.exitCode == 0)
    XCTAssertTrue(successResult.stdout == "Success output")
    XCTAssertTrue(successResult.stderr.isEmpty)

    let failureResult = ProcessResult(
      exitCode: 1,
      stdout: "",
      stderr: "Error occurred"
    )
    XCTAssertTrue(failureResult.isSuccess == false)
    XCTAssertTrue(failureResult.exitCode == 1)
    XCTAssertTrue(failureResult.stdout.isEmpty)
    XCTAssertTrue(failureResult.stderr == "Error occurred")
  }

  func testProcessRunnerEcho() throws {
    let runner = ProcessRunner()
    let result = try runner.run(
      executable: "/bin/echo",
      arguments: ["Hello, World!"],
      currentDirectory: nil
    )

    XCTAssertTrue(result.isSuccess)
    XCTAssertTrue(result.exitCode == 0)
    XCTAssertTrue(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello, World!")
    XCTAssertTrue(result.stderr.isEmpty)
  }

  func testProcessRunnerWithDirectory() throws {
    let runner = ProcessRunner()
    let tempDir = FileManager.default.temporaryDirectory

    let result = try runner.run(
      executable: "/bin/pwd",
      arguments: [],
      currentDirectory: tempDir
    )

    XCTAssertTrue(result.isSuccess)

    let outputPath = result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    let expectedPath = tempDir.path
    XCTAssertTrue(outputPath.hasSuffix(expectedPath.split(separator: "/").suffix(3).joined(separator: "/")) || outputPath == expectedPath)
  }

  func testProcessRunnerFailure() throws {
    let runner = ProcessRunner()
    let result = try runner.run(
      executable: "/bin/ls",
      arguments: ["/nonexistent/directory/that/should/not/exist"],
      currentDirectory: nil
    )

    XCTAssertTrue(!result.isSuccess)
    XCTAssertTrue(result.exitCode != 0)
    XCTAssertTrue(!result.stderr.isEmpty)
  }

  func testProcessRunnerSwift() throws {
    let runner = ProcessRunner()
    let result = try runner.run(
      executable: "/usr/bin/swift",
      arguments: ["--version"],
      currentDirectory: nil
    )

    XCTAssertTrue(result.isSuccess)
    XCTAssertTrue(result.stdout.contains("Swift") || result.stderr.contains("Swift"))
  }

  func testMockProcessRunner() throws {
    let mock = MockProcessRunner()


    mock.mockResults = [
      ProcessResult(exitCode: 0, stdout: "First result", stderr: ""),
      ProcessResult(exitCode: 1, stdout: "", stderr: "Second error"),
    ]


    let result1 = try mock.run(
      executable: "/bin/test",
      arguments: ["arg1", "arg2"],
      currentDirectory: nil
    )

    XCTAssertTrue(result1.exitCode == 0)
    XCTAssertTrue(result1.stdout == "First result")
    XCTAssertTrue(result1.stderr.isEmpty)


    let result2 = try mock.run(
      executable: "/bin/test2",
      arguments: ["arg3"],
      currentDirectory: URL(fileURLWithPath: "/tmp")
    )

    XCTAssertTrue(result2.exitCode == 1)
    XCTAssertTrue(result2.stdout.isEmpty)
    XCTAssertTrue(result2.stderr == "Second error")


    XCTAssertTrue(mock.capturedCalls.count == 2)
    XCTAssertTrue(mock.capturedCalls[0].executable == "/bin/test")
    XCTAssertTrue(mock.capturedCalls[0].arguments == ["arg1", "arg2"])
    XCTAssertTrue(mock.capturedCalls[0].directory == nil)
    XCTAssertTrue(mock.capturedCalls[1].executable == "/bin/test2")
    XCTAssertTrue(mock.capturedCalls[1].arguments == ["arg3"])
    XCTAssertTrue(mock.capturedCalls[1].directory?.path == "/tmp")
  }

  func testMockProcessRunnerDefault() throws {
    let mock = MockProcessRunner()

    let result = try mock.run(
      executable: "/bin/test",
      arguments: [],
      currentDirectory: nil
    )

    XCTAssertTrue(result.exitCode == 0)
    XCTAssertTrue(result.stdout.isEmpty)
    XCTAssertTrue(result.stderr.isEmpty)
  }

  func testMockProcessRunnerReset() throws {
    let mock = MockProcessRunner()

    mock.mockResults = [ProcessResult(exitCode: 42, stdout: "Test", stderr: "")]

    _ = try mock.run(executable: "/bin/test", arguments: [], currentDirectory: nil)
    XCTAssertTrue(mock.capturedCalls.count == 1)

    mock.reset()

    XCTAssertTrue(mock.capturedCalls.isEmpty)


    let result = try mock.run(executable: "/bin/test", arguments: [], currentDirectory: nil)
    XCTAssertTrue(result.exitCode == 42)
  }

  func testProcessRunnerMultipleArguments() throws {
    let runner = ProcessRunner()
    let result = try runner.run(
      executable: "/bin/echo",
      arguments: ["-n", "arg1", "arg2", "arg3"],
      currentDirectory: nil
    )

    XCTAssertTrue(result.isSuccess)
    XCTAssertTrue(result.stdout == "arg1 arg2 arg3")
  }
}
