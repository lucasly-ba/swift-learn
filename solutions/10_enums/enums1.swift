// enums1.swift
//
// Enums define a common type for a group of related values.
// They're type-safe and can have raw values.
//
// Fix the enum definitions and usage to make the tests pass.

enum CompassDirection {
    case north, south, east, west
}

enum Priority: Int {
    case low = 1
    case medium
    case high
}

enum FileExtension: String {
    case swift
    case python = "py"
    case javascript
}

func getDirection() -> CompassDirection {
    return .north
}

func getPriorityValue() -> Int {
    let priority = Priority.high
    return priority.rawValue
}

func getExtension(for language: String) -> FileExtension? {
    return FileExtension(rawValue: language)
}

func main() {
    print("direction \(getDirection()), priority \(getPriorityValue()), py -> \(getExtension(for: "py")?.rawValue ?? "?")")

    test("Basic enum usage") {
        let direction = getDirection()
        assertTrue(direction == .north, "Should return north")

        // Test all cases exist
        let _: CompassDirection = .south
        let _: CompassDirection = .east
        let _: CompassDirection = .west
    }

    test("Enum raw values") {
        assertEqual(Priority.low.rawValue, 1, "Low priority = 1")
        assertEqual(Priority.medium.rawValue, 2, "Medium priority = 2")
        assertEqual(Priority.high.rawValue, 3, "High priority = 3")

        assertEqual(getPriorityValue(), 3, "High priority value")
    }

    test("String raw values") {
        assertEqual(FileExtension.swift.rawValue, "swift", "Swift extension")
        assertEqual(FileExtension.python.rawValue, "py", "Python extension")
        assertEqual(FileExtension.javascript.rawValue, "javascript", "JS extension")

        assertEqual(getExtension(for: "py"), .python, "Create from raw value")
        assertNil(getExtension(for: "java"), "Invalid raw value returns nil")
    }

    runTests()
}
