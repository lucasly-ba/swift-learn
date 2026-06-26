// optionals4.swift
//
// The nil-coalescing operator (??) provides a default value for optionals.
// Multiple ?? operators can be chained for fallback values.
//
// Fix the nil-coalescing operations to make the tests pass.

func userPreferences() -> (theme: String, fontSize: Int, notifications: Bool) {
    // Simulating user preferences that might not be set
    let savedTheme: String? = nil
    let savedFontSize: Int? = nil
    let savedNotifications: Bool? = false

    let theme = savedTheme ?? "light"

    let recommendedSize: Int? = nil
    let fontSize = savedFontSize ?? recommendedSize ?? 16

    let notifications = (savedNotifications ?? true) && false

    return (theme, fontSize, notifications)
}

func parseConfiguration() -> [String: Any] {
    // Simulating config values that might be missing
    let config: [String: Any?] = [
        "host": nil,
        "port": 8080,
        "timeout": nil,
        "debug": nil
    ]

    var result: [String: Any] = [:]

    result["host"] = (config["host"] ?? nil) ?? "localhost"

    result["port"] = (config["port"] ?? nil) ?? 3000

    result["timeout"] = (config["timeout"] ?? nil) ?? 30

    result["debug"] = (config["debug"] ?? nil) ?? false

    return result
}

func main() {
    let p = userPreferences()
    print("theme \(p.theme), fontSize \(p.fontSize), notifications \(p.notifications)")

    test("User preferences with defaults") {
        let prefs = userPreferences()
        assertEqual(prefs.theme, "light", "Should use default theme")
        assertEqual(prefs.fontSize, 16, "Should use final default size")
        assertFalse(prefs.notifications, "Should be false after AND operation")
    }

    test("Configuration parsing") {
        let config = parseConfiguration()
        assertEqual(config["host"] as? String, "localhost", "Default host")
        assertEqual(config["port"] as? Int, 8080, "Existing port value")
        assertEqual(config["timeout"] as? Int, 30, "Default timeout")
        assertEqual(config["debug"] as? Bool, false, "Default debug flag")
    }

    runTests()
}
