// protocols6.swift
//
// Comparable lets you sort values and use <, >, and so on. CustomStringConvertible
// lets you decide how a value prints by giving it a `description`.
//
// Fix the type so it conforms to Comparable and CustomStringConvertible.

struct Version: Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int

    var description: String {
        return "\(major).\(minor)"
    }

    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        return lhs.minor < rhs.minor
    }
}

func test() {
    let versions = [
        Version(major: 2, minor: 0),
        Version(major: 1, minor: 5),
        Version(major: 1, minor: 2),
    ]
    let sorted = versions.sorted()
    assertEqual(sorted.map { $0.description }, ["1.2", "1.5", "2.0"], "versions sort ascending")
    assertTrue(Version(major: 1, minor: 0) < Version(major: 1, minor: 1), "1.0 is less than 1.1")
    assertEqual("\(Version(major: 3, minor: 4))", "3.4", "description prints major.minor")
}

func main() {
    print("1.2 < 2.0 is \(Version(major: 1, minor: 2) < Version(major: 2, minor: 0))")

    test()
    runTests()
}
