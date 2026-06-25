import XCTest
import Foundation
@testable import Swiftlings

final class ExerciseRunnerSimplifiedTests: XCTestCase {
  func testCompilationError() {
    let error = CompilationError(message: "Failed to compile")
    XCTAssertTrue(error.message == "Failed to compile")
  }

  func testExerciseResultProperties() {
    let success = ExerciseResult.success(output: "Test passed")
    XCTAssertTrue(success.isSuccess == true)

    let compilationError = ExerciseResult.compilationError(message: "Syntax error")
    XCTAssertTrue(compilationError.isSuccess == false)

    let testFailure = ExerciseResult.testFailure(message: "Assertion failed")
    XCTAssertTrue(testFailure.isSuccess == false)
  }

  func testExerciseResultPatterns() {
    let results: [ExerciseResult] = [
      .success(output: "Output"),
      .compilationError(message: "Error"),
      .testFailure(message: "Failure"),
    ]

    for result in results {
      switch result {
        case .success(let output):
          XCTAssertTrue(result.isSuccess)
          XCTAssertTrue(!output.isEmpty)
        case .compilationError(let message):
          XCTAssertTrue(!result.isSuccess)
          XCTAssertTrue(!message.isEmpty)
        case .testFailure(let message):
          XCTAssertTrue(!result.isSuccess)
          XCTAssertTrue(!message.isEmpty)
      }
    }
  }
}
