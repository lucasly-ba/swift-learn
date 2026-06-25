import XCTest
import Foundation
@testable import Swiftlings

final class ConfigurationTests: XCTestCase {
  func testExecutablePaths() {
    XCTAssertTrue(Configuration.Executables.git == "/usr/bin/git")
    XCTAssertTrue(Configuration.Executables.swiftc == "/usr/bin/swiftc")
  }

  func testFilePaths() {
    XCTAssertTrue(Configuration.Paths.stateFileName == ".swiftlings-state.json")
    XCTAssertTrue(Configuration.Paths.exerciseInfoFile == "Exercises/info.json")
    XCTAssertTrue(Configuration.Paths.assertSourcePath == "Sources/Swiftlings/Core/Assert.swift")
  }

  func testUIConfiguration() {
    XCTAssertTrue(Configuration.UI.progressBarWidth == 120)
    XCTAssertTrue(Configuration.UI.defaultTerminalWidth == 80)
  }

  func testExerciseConfiguration() {
    XCTAssertTrue(Configuration.Exercise.tempDirectoryPrefix == "swiftlings")
    XCTAssertTrue(Configuration.Exercise.compiledExecutableName == "exercise")
    XCTAssertTrue(Configuration.Exercise.mainFileName == "main.swift")
  }

  func testConfigurationValuesAreReasonable() {

    XCTAssertTrue(Configuration.Executables.git.hasPrefix("/"))
    XCTAssertTrue(Configuration.Executables.swiftc.hasPrefix("/"))


    XCTAssertTrue(Configuration.UI.progressBarWidth > 0)
    XCTAssertTrue(Configuration.UI.defaultTerminalWidth > 0)


    XCTAssertTrue(!Configuration.Paths.stateFileName.isEmpty)
    XCTAssertTrue(!Configuration.Paths.exerciseInfoFile.isEmpty)
    XCTAssertTrue(!Configuration.Paths.assertSourcePath.isEmpty)


    XCTAssertTrue(!Configuration.Exercise.tempDirectoryPrefix.isEmpty)
    XCTAssertTrue(!Configuration.Exercise.compiledExecutableName.isEmpty)
    XCTAssertTrue(!Configuration.Exercise.mainFileName.isEmpty)


    XCTAssertTrue(Configuration.Paths.stateFileName.hasPrefix("."))


    XCTAssertTrue(Configuration.Exercise.mainFileName.hasSuffix(".swift"))
  }

  func testPathConsistency() {

    XCTAssertTrue(Configuration.Paths.assertSourcePath.hasSuffix("Assert.swift"))


    XCTAssertTrue(Configuration.Paths.exerciseInfoFile.hasPrefix("Exercises/"))


    XCTAssertTrue(Configuration.Paths.exerciseInfoFile.hasSuffix(".json"))
  }
}
