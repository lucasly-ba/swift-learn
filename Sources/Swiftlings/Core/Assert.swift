import Foundation

/// Custom assertion framework for Swiftlings exercises
public enum SwiftlingsAssert {
  // Exercises run as a single-threaded program, so this shared state is only
  // ever touched from one thread. nonisolated(unsafe) says that explicitly.
  private nonisolated(unsafe) static var testResults: [TestResult] = []
  private nonisolated(unsafe) static var currentTest: String = ""

  public struct TestResult {
    let testName: String
    let passed: Bool
    let message: String
    let file: String
    let line: Int
  }

  /// Assert that two values are equal
  public static func assertEqual<T: Equatable>(
    _ actual: T,
    _ expected: T,
    _ message: String = "",
    file: String = #file,
    line: Int = #line
  ) {
    let passed = actual == expected
    let resultMessage = passed ? "✓ Passed" : "✗ Expected \(expected), but got \(actual)"
    let finalMessage = message.isEmpty ? resultMessage : "\(message): \(resultMessage)"

    testResults.append(TestResult(
      testName: currentTest,
      passed: passed,
      message: finalMessage,
      file: file,
      line: line
    ))
  }

  /// Assert that a condition is true
  public static func assertTrue(
    _ condition: Bool,
    _ message: String = "Assertion failed",
    file: String = #file,
    line: Int = #line
  ) {
    let passed = condition
    let resultMessage = passed ? "✓ Passed" : "✗ \(message)"

    testResults.append(TestResult(
      testName: currentTest,
      passed: passed,
      message: resultMessage,
      file: file,
      line: line
    ))
  }

  /// Assert that a condition is false
  public static func assertFalse(
    _ condition: Bool,
    _ message: String = "Expected false but got true",
    file: String = #file,
    line: Int = #line
  ) {
    assertTrue(!condition, message, file: file, line: line)
  }

  /// Assert that two values are not equal
  public static func assertNotEqual<T: Equatable>(
    _ actual: T,
    _ expected: T,
    _ message: String = "",
    file: String = #file,
    line: Int = #line
  ) {
    let passed = actual != expected
    let resultMessage = passed ? "✓ Passed" : "✗ Expected values to be different, but both were \(actual)"
    let finalMessage = message.isEmpty ? resultMessage : "\(message): \(resultMessage)"

    testResults.append(TestResult(
      testName: currentTest,
      passed: passed,
      message: finalMessage,
      file: file,
      line: line
    ))
  }

  /// Assert that a value is nil
  public static func assertNil<T>(
    _ value: T?,
    _ message: String = "Expected nil",
    file: String = #file,
    line: Int = #line
  ) {
    let passed = value == nil
    let resultMessage = passed ? "✓ Passed" : "✗ Expected nil, but got \(value!)"
    let finalMessage = message.isEmpty ? resultMessage : "\(message): \(resultMessage)"

    testResults.append(TestResult(
      testName: currentTest,
      passed: passed,
      message: finalMessage,
      file: file,
      line: line
    ))
  }

  /// Assert that a value is not nil
  public static func assertNotNil<T>(
    _ value: T?,
    _ message: String = "Expected non-nil value",
    file: String = #file,
    line: Int = #line
  ) {
    let passed = value != nil
    let resultMessage = passed ? "✓ Passed" : "✗ \(message)"

    testResults.append(TestResult(
      testName: currentTest,
      passed: passed,
      message: resultMessage,
      file: file,
      line: line
    ))
  }

  /// Run a test with a given name
  public static func test(_ name: String, _ testBlock: () -> Void) {
    currentTest = name
    testBlock()
  }

  /// Run all tests and print results
  public static func runTests() {
    if testResults.isEmpty {
      print("⚠️  No tests were run!")
      exit(1)
    }

    let failedTests = testResults.filter { !$0.passed }

    // On success, stay quiet so the only thing in the "Output" panel is the
    // exercise's own output, the way Rustlings does it. The runner reports the
    // pass with "Exercise done" and the exit code.
    if failedTests.isEmpty {
      exit(0)
    }

    // On failure, show just the assertions that failed and where.
    for result in failedTests {
      let testName = result.testName.isEmpty ? "Test" : result.testName
      print("\(testName): \(result.message)")
      let fileName = URL(fileURLWithPath: result.file).lastPathComponent
      print("  at \(fileName):\(result.line)")
    }
    exit(1)
  }

  /// Clear all test results (useful for testing)
  public static func reset() {
    testResults.removeAll()
    currentTest = ""
  }
}

public func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: String = #file, line: Int = #line) {
  SwiftlingsAssert.assertEqual(actual, expected, message, file: file, line: line)
}

public func assertTrue(_ condition: Bool, _ message: String = "Assertion failed", file: String = #file, line: Int = #line) {
  SwiftlingsAssert.assertTrue(condition, message, file: file, line: line)
}

public func assertFalse(_ condition: Bool, _ message: String = "Expected false but got true", file: String = #file, line: Int = #line) {
  SwiftlingsAssert.assertFalse(condition, message, file: file, line: line)
}

public func assertNotEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: String = #file, line: Int = #line) {
  SwiftlingsAssert.assertNotEqual(actual, expected, message, file: file, line: line)
}

public func assertNil<T>(_ value: T?, _ message: String = "Expected nil", file: String = #file, line: Int = #line) {
  SwiftlingsAssert.assertNil(value, message, file: file, line: line)
}

public func assertNotNil<T>(_ value: T?, _ message: String = "Expected non-nil value", file: String = #file, line: Int = #line) {
  SwiftlingsAssert.assertNotNil(value, message, file: file, line: line)
}

public func test(_ name: String, _ testBlock: () -> Void) {
  SwiftlingsAssert.test(name, testBlock)
}

public func runTests() {
  SwiftlingsAssert.runTests()
}
