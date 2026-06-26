import ArgumentParser
import Foundation
import Rainbow

struct InitCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "init",
    abstract: "Initialize a new Swiftlings project with exercises"
  )
  
  @Option(name: .shortAndLong, help: "The name of the directory to create")
  var projectName: String = "swiftlings"
  
  @Flag(name: .long, help: "Force overwrite if directory already exists")
  var force: Bool = false
  
  mutating func run() throws {
    let fileManager = FileManager.default
    let currentPath = fileManager.currentDirectoryPath
    let projectPath = "\(currentPath)/\(projectName)"
    
    /// Check if directory already exists
    if fileManager.fileExists(atPath: projectPath) && !force {
      print("A directory with the name `\(projectName)` already exists.")
      print("Move or remove it, run again with --force to overwrite, or pick another name with --project-name.")
      throw ExitCode.failure
    }

    print("This command will create the directory `\(projectName)/` which will contain the exercises.")
    print("Press ENTER to continue ", terminator: "")
    fflush(nil)
    _ = readLine()

    /// Remove existing directory if force flag is set
    if force && fileManager.fileExists(atPath: projectPath) {
      try fileManager.removeItem(atPath: projectPath)
    }

    /// Clone the exercises repository
    let cloneResult = Process.execute(
      Configuration.Executables.git,
      arguments: [
        "clone",
        "--depth", "1",
        "--branch", "main",
        "https://github.com/lucasly-ba/swiftlings-linux.git",
        projectName
      ]
    )

    guard cloneResult.exitCode == 0 else {
      print("Failed to download the exercises.".red)
      print(cloneResult.stderr)
      throw ExitCode.failure
    }

    /// Remove .git directory to disconnect from the original repo
    let gitPath = "\(projectPath)/.git"
    if fileManager.fileExists(atPath: gitPath) {
      try fileManager.removeItem(atPath: gitPath)
    }

    print("")
    print("Initialization done ✓".green)
    print("")
    print("Run `cd \(projectName)` to go into the generated directory.")
    print("Then run `swiftlings` to get started.")
  }
}

/// Helper extension for Process
extension Process {
  static func execute(
    _ executablePath: String,
    arguments: [String] = [],
    currentDirectoryPath: String? = nil
  ) -> (exitCode: Int32, stdout: String, stderr: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executablePath)
    process.arguments = arguments
    
    if let currentPath = currentDirectoryPath {
      process.currentDirectoryURL = URL(fileURLWithPath: currentPath)
    }
    
    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe
    
    do {
      try process.run()
      process.waitUntilExit()
      
      let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
      let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
      
      let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
      let stderr = String(data: stderrData, encoding: .utf8) ?? ""
      
      return (process.terminationStatus, stdout, stderr)
    } catch {
      return (-1, "", error.localizedDescription)
    }
  }
}