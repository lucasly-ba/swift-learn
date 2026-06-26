// property_wrappers4.swift
//
// Property wrappers compose: stacking two of them applies both behaviours to a
// property. They can also be generic and constrained. This exercise combines
// the ideas from the earlier ones.
//
// Fix the property wrappers to make the tests pass.

// Clamp an Int into a range.
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

// Record every change in a shared log so we can prove composition ran.
nonisolated(unsafe) var changeLog: [String] = []

@propertyWrapper
struct Logged<Value> {
    private var value: Value
    private let label: String

    init(wrappedValue: Value, _ label: String) {
        self.value = wrappedValue
        self.label = label
    }

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            changeLog.append("\(label)=\(newValue)")
        }
    }
}

// Round a Double to a fixed number of decimal places on every write.
@propertyWrapper
struct Rounded {
    private var value: Double
    private let places: Int

    init(wrappedValue: Double, places: Int) {
        self.places = places
        self.value = Rounded.round(wrappedValue, to: places)
    }

    var wrappedValue: Double {
        get { value }
        set { value = Rounded.round(newValue, to: places) }
    }

    private static func round(_ x: Double, to places: Int) -> Double {
        var factor = 1.0
        for _ in 0..<places { factor *= 10 }
        return (x * factor).rounded() / factor
    }
}

// A generic wrapper that falls back to a default whenever the collection is empty.
@propertyWrapper
struct NonEmpty<C: Collection> {
    private var value: C
    private let fallback: C

    init(wrappedValue: C, or fallback: C) {
        self.fallback = fallback
        self.value = wrappedValue.isEmpty ? fallback : wrappedValue
    }

    var wrappedValue: C {
        get { value }
        set { value = newValue.isEmpty ? fallback : newValue }
    }
}

struct Settings {
    @Logged("volume") @Clamped(0...100) var volume: Int = 50
    @Rounded(places: 2) var price: Double = 0
    @NonEmpty(or: "Untitled") var title: String = ""
}

func main() {
    var demo = Settings()
    demo.volume = 150
    print("volume \(demo.volume), title \(demo.title)")

    test("Logged and Clamped compose") {
        changeLog = []
        var settings = Settings()

        settings.volume = 150
        assertEqual(settings.volume, 100, "Clamped to 100")

        settings.volume = -20
        assertEqual(settings.volume, 0, "Clamped to 0")

        // The Logged wrapper wraps the Clamped wrapper, so both run on every
        // write: there should be one log entry per assignment.
        assertEqual(changeLog.count, 2, "Logged recorded both writes")
    }

    test("Rounded rounds on write") {
        var settings = Settings()

        settings.price = 3.14159
        assertEqual(settings.price, 3.14, "Rounded to 2 places")

        settings.price = 19.999
        assertEqual(settings.price, 20.0, "Rounds up")
    }

    test("NonEmpty falls back") {
        var settings = Settings()
        assertEqual(settings.title, "Untitled", "Empty initial value uses the fallback")

        settings.title = "Report"
        assertEqual(settings.title, "Report", "A non-empty value is kept")

        settings.title = ""
        assertEqual(settings.title, "Untitled", "Empty again falls back")
    }

    runTests()
}
