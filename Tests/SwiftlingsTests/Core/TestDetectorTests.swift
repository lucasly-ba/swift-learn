import XCTest
import Foundation
@testable import Swiftlings

final class TestDetectorTests: XCTestCase {

  class MockFileManager: FileManager {
    var fileExistsResponses: [String: Bool] = [:]

    override func fileExists(atPath path: String) -> Bool {
      return fileExistsResponses[path] ?? false
    }
  }


  func withTemporaryFile(content: String, _ test: (URL) throws -> Void) throws {
    let tempDir = FileManager.default.temporaryDirectory
    let tempFile = tempDir.appendingPathComponent(UUID().uuidString + ".swift")

    try content.write(to: tempFile, atomically: true, encoding: .utf8)

    defer {
      try? FileManager.default.removeItem(at: tempFile)
    }

    try test(tempFile)
  }

  func testDetectsRunTests() throws {
    let detector = TestDetector()

    let content = """
      import Foundation

      func testAddition() {
        assertEqual(2 + 2, 4)
      }

      runTests()
      """

    try withTemporaryFile(content: content) { file in
      XCTAssertTrue(detector.usesTestApproach(exercisePath: file) == true)
    }
  }

  func testDetectsSwiftlingsAssert() throws {
    let detector = TestDetector()

    let content = """
      import SwiftlingsAssert

      func main() {
        print("Hello")
      }
      """

    try withTemporaryFile(content: content) { file in
      XCTAssertTrue(detector.usesTestApproach(exercisePath: file) == true)
    }
  }

  func testDetectsAssertEqual() throws {
    let detector = TestDetector()

    let content = """
      func testMath() {
        assertEqual(10 / 2, 5)
        assertEqual("Hello", "Hello")
      }
      """

    try withTemporaryFile(content: content) { file in
      XCTAssertTrue(detector.usesTestApproach(exercisePath: file) == true)
    }
  }

  func testDetectsAssertTrue() throws {
    let detector = TestDetector()

    let content = """
      func testConditions() {
        assertTrue(5 > 3)
        assertTrue(isValid())
      }
      """

    try withTemporaryFile(content: content) { file in
      XCTAssertTrue(detector.usesTestApproach(exercisePath: file) == true)
    }
  }

  func testNonTestFile() throws {
    let detector = TestDetector()

    let content = """
      import Foundation

      func main() {
        print("Hello, World!")
        let result = calculate(5, 10)
        print(result)
      }

      func calculate(_ a: Int, _ b: Int) -> Int {
        return a + b
      }
      """

    try withTemporaryFile(content: content) { file in
      XCTAssertTrue(detector.usesTestApproach(exercisePath: file) == false)
    }
  }

  func testFileReadError() {
    let detector = TestDetector()


    let nonExistentFile = URL(fileURLWithPath: "/tmp/nonexistent-\(UUID().uuidString).swift")
    XCTAssertTrue(detector.usesTestApproach(exercisePath: nonExistentFile) == false)
  }

  func testVariousTestPatterns() throws {
    let detector = TestDetector()

    let testCases = [

      ("func main() { runTests() }", true),
      ("runTests()", true),
      ("  runTests()  ", true),


      ("assertEqual(a, b)", true),
      ("  assertEqual(expected, actual)  ", true),


      ("assertTrue(condition)", true),
      ("assertTrue(x > 0)", true),


      ("import SwiftlingsAssert", true),
      ("@testable import SwiftlingsAssert", true),


      ("func run() { print(\"test\") }", false),
      ("// runTests()", true),
      ("let runTestsVar = true", false),
      ("print(\"assertEqual\")", true),
    ]

    for (content, expectedResult) in testCases {
      try withTemporaryFile(content: content) { file in
        XCTAssertTrue(
          detector.usesTestApproach(exercisePath: file) == expectedResult,
          "Failed for content: \(content)"
        )
      }
    }
  }

  func testCaseSensitivity() throws {
    let detector = TestDetector()


    let wrongCaseContent = """
      RUNTESTS()
      AssertEqual(1, 1)
      ASSERTTRUE(true)
      import swiftlingsassert
      """

    try withTemporaryFile(content: wrongCaseContent) { file in
      XCTAssertTrue(detector.usesTestApproach(exercisePath: file) == false)
    }
  }

  func testMixedContent() throws {
    let detector = TestDetector()

    let mixedContent = """
      import Foundation


      func calculateSum(_ a: Int, _ b: Int) -> Int {
        return a + b
      }

      func testCalculateSum() {
        assertEqual(calculateSum(2, 3), 5)
        assertEqual(calculateSum(-1, 1), 0)
        assertEqual(calculateSum(0, 0), 0)
      }

      func testMultiplication() {
        let result = 4 * 5
        assertTrue(result == 20)
      }


      runTests()
      """

    try withTemporaryFile(content: mixedContent) { file in
      XCTAssertTrue(detector.usesTestApproach(exercisePath: file) == true)
    }
  }
}
