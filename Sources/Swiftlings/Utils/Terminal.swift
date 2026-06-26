import Foundation
import Rainbow
#if canImport(Glibc)
  import Glibc
#elseif canImport(Darwin)
  import Darwin
#endif

/// Color options for terminal output
enum TerminalColor {
  case blue, cyan, green, red, yellow
}

/// Terminal utilities for formatted output
enum Terminal {
  /// Print success message in green
  static func success(_ message: String) {
    print("✅ \(message)".green)
  }

  /// Print error message in red
  static func error(_ message: String) {
    print("❌ \(message)".red)
  }

  /// Print warning message in yellow
  static func warning(_ message: String) {
    print("⚠️  \(message)".yellow)
  }

  /// Print info message in blue
  static func info(_ message: String) {
    print("ℹ️  \(message)".blue)
  }

  /// Print a progress message in cyan
  static func progress(_ message: String) {
    print("🔄 \(message)".cyan)
  }

  /// Clear the terminal screen
  static func clear() {
    print("\u{001B}[2J\u{001B}[H", terminator: "")
  }

  /// The terminal width in columns, so things like the progress bar can fit on
  /// one line. Falls back to $COLUMNS, then 80, when there is no real terminal.
  static func width() -> Int {
    var size = winsize()
    if ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size) == 0, size.ws_col > 0 {
      return Int(size.ws_col)
    }
    if let columns = ProcessInfo.processInfo.environment["COLUMNS"], let value = Int(columns), value > 0 {
      return value
    }
    return Configuration.UI.defaultTerminalWidth
  }

  /// The terminal height in rows, so a full-screen list can size its viewport.
  /// Falls back to $LINES, then 24, when there is no real terminal.
  static func height() -> Int {
    var size = winsize()
    if ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &size) == 0, size.ws_row > 0 {
      return Int(size.ws_row)
    }
    if let lines = ProcessInfo.processInfo.environment["LINES"], let value = Int(lines), value > 0 {
      return value
    }
    return 24
  }

  /// Move cursor to specific position
  static func moveCursor(to position: (row: Int, column: Int)) {
    print("\u{001B}[\(position.row);\(position.column)H", terminator: "")
  }

  /// Print colored text using Rainbow
  static func colored(_ text: String, color: TerminalColor) -> String {
    switch color {
      case .blue:
        return text.blue
      case .cyan:
        return text.cyan
      case .green:
        return text.green
      case .red:
        return text.red
      case .yellow:
        return text.yellow
    }
  }
}
