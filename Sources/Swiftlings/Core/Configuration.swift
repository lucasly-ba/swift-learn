import Foundation

/// Central configuration for Swiftlings
enum Configuration {
  /// Executable paths, resolved from PATH so the toolchain is found wherever it
  /// lives (e.g. the Nix-provided `swiftc`/`git` on Linux, not `/usr/bin`).
  enum Executables {
    static let git = resolve("git") ?? "/usr/bin/git"
    static let swiftc = resolve("swiftc") ?? "/usr/bin/swiftc"

    /// Find an executable by walking the PATH environment variable.
    private static func resolve(_ name: String) -> String? {
      let pathEnv = ProcessInfo.processInfo.environment["PATH"] ?? ""
      for dir in pathEnv.split(separator: ":") {
        let candidate = "\(dir)/\(name)"
        if FileManager.default.isExecutableFile(atPath: candidate) {
          return candidate
        }
      }
      return nil
    }
  }

  /// File paths
  enum Paths {
    static let stateFileName = ".swiftlings-state.json"
    static let exerciseInfoFile = "Exercises/info.json"
    static let assertSourcePath = "Sources/Swiftlings/Core/Assert.swift"
  }

  /// UI Configuration
  enum UI {
    static let progressBarWidth = 120
    static let defaultTerminalWidth = 80
  }

  /// Exercise Configuration
  enum Exercise {
    static let tempDirectoryPrefix = "swiftlings"
    static let compiledExecutableName = "exercise"
    static let mainFileName = "main.swift"
  }
}
