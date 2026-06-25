import Foundation
#if canImport(Glibc)
  import Glibc
#elseif canImport(Darwin)
  import Darwin
#endif

/// Utility for handling raw terminal input without requiring Enter key
class RawTerminalInput {
  private var originalTerminalSettings: termios?

  init() {
    // Save original terminal settings
    originalTerminalSettings = termios()
    if var settings = originalTerminalSettings {
      tcgetattr(STDIN_FILENO, &settings)
      originalTerminalSettings = settings
    }
  }

  deinit {
    // Restore original terminal settings
    if var original = originalTerminalSettings {
      tcsetattr(STDIN_FILENO, TCSANOW, &original)
    }
  }

  /// Enable raw mode for immediate keypress detection
  func enableRawMode() {
    var raw = termios()
    tcgetattr(STDIN_FILENO, &raw)

    // Disable canonical mode (line buffering) and echo
    // `c_lflag` is `tcflag_t`, whose width differs across platforms
    // (UInt on Darwin, UInt32 on Glibc); cast through tcflag_t for both.
    raw.c_lflag &= ~(tcflag_t(ICANON) | tcflag_t(ECHO))

    // Set minimum characters to read - handle tuple-based c_cc on macOS
    withUnsafeMutableBytes(of: &raw.c_cc) { ptr in
      ptr[Int(VMIN)] = 1
      ptr[Int(VTIME)] = 0
    }

    tcsetattr(STDIN_FILENO, TCSANOW, &raw)
  }

  /// Disable raw mode and restore normal terminal settings
  func disableRawMode() {
    if var original = originalTerminalSettings {
      tcsetattr(STDIN_FILENO, TCSANOW, &original)
    }
  }

  /// Read a single character without waiting for Enter
  func readKey() -> Character? {
    var buffer = [UInt8](repeating: 0, count: 1)
    let bytesRead = read(STDIN_FILENO, &buffer, 1)

    if bytesRead > 0 {
      return Character(UnicodeScalar(buffer[0]))
    }

    return nil
  }
}
