// property_wrappers1.swift
//
// Property wrappers encapsulate property storage and access logic.
// They provide a way to define reusable property behaviors.
//
// Fix the property wrapper implementations to make the tests pass.

import Foundation

@propertyWrapper
struct Capitalized {
    private var value: String = ""

    init(wrappedValue: String) {
        self.value = wrappedValue.capitalized
    }

    var wrappedValue: String {
        get { value }
        set { value = newValue.capitalized }
    }
}

@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
}

@propertyWrapper
struct Validated<Value> {
    private var value: Value
    private let validator: (Value) -> Bool
    private var isValid: Bool = true

    init(wrappedValue: Value, _ validator: @escaping (Value) -> Bool) {
        self.value = wrappedValue
        self.validator = validator
        self.isValid = validator(wrappedValue)
    }

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            isValid = validator(newValue)
        }
    }

    var projectedValue: Bool {
        return isValid
    }
}

struct User {
    @Capitalized var name: String = ""
    @Clamped(0...100) var age: Int = 0
    @Validated({ $0.contains("@") }) var email: String = ""
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

struct Settings {
    @UserDefault(key: "username", defaultValue: "Guest")
    var username: String

    @UserDefault(key: "volume", defaultValue: 50)
    var volume: Int
}

func main() {
    var user = User(name: "john doe", age: 150, email: "john@example.com")
    print("name \(user.name), age \(user.age), email valid \(user.$email)")

    test("Basic property wrapper") {
        var user = User(name: "john doe", age: 25, email: "john@example.com")

        assertEqual(user.name, "John Doe", "Name should be capitalized")

        user.name = "alice smith"
        assertEqual(user.name, "Alice Smith", "Name should be capitalized on set")
    }

    test("Property wrapper with constraints") {
        var user = User(name: "Test", age: 150, email: "test@test.com")

        assertEqual(user.age, 100, "Age should be clamped to maximum")

        user.age = -10
        assertEqual(user.age, 0, "Age should be clamped to minimum")

        user.age = 50
        assertEqual(user.age, 50, "Valid age should not be clamped")
    }

    test("Projected value") {
        var user = User(name: "Test", age: 30, email: "invalid-email")

        assertFalse(user.$email, "Invalid email should project false")

        user.email = "valid@email.com"
        assertTrue(user.$email, "Valid email should project true")

        user.email = "another-invalid"
        assertFalse(user.$email, "Invalid email should project false again")
    }

    test("UserDefaults wrapper") {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "volume")

        var settings = Settings()

        assertEqual(settings.username, "Guest", "Should use default value")
        assertEqual(settings.volume, 50, "Should use default volume")

        settings.username = "Alice"
        settings.volume = 75

        let newSettings = Settings()
        assertEqual(newSettings.username, "Alice", "Should read from UserDefaults")
        assertEqual(newSettings.volume, 75, "Should read volume from UserDefaults")
    }

    runTests()
}
