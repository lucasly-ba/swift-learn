import Foundation

/// Represents a single exercise in Swiftlings
struct Exercise: Codable, Equatable {
  let name: String

  let dir: String

  let hint: String

  let dependencies: [String]?

  /// Link to the relevant chapter of The Swift Programming Language (or other
  /// official docs). Optional so older metadata without it still decodes.
  let doc: String?

  init(name: String, dir: String, hint: String, dependencies: [String]? = nil, doc: String? = nil) {
    self.name = name
    self.dir = dir
    self.hint = hint
    self.dependencies = dependencies
    self.doc = doc
  }

  var filePath: String {
    "Exercises/\(dir)/\(name).swift"
  }

  private enum CodingKeys: String, CodingKey {
    case name
    case dir
    case hint
    case dependencies
    case doc
  }
}
