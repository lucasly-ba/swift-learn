// property_wrappers3.swift
//
// A property wrapper can expose a second value through `projectedValue`, reached
// with the `$` prefix. Here we build wrappers whose projection reports extra
// information about the stored value.
//
// Fix the property wrappers to make the tests pass.

// Clamp into a range, and project whether the last write had to be clamped.
@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>
    private(set) var wasClamped = false

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        let clamped = min(max(wrappedValue, range.lowerBound), range.upperBound)
        self.value = clamped
        self.wasClamped = clamped != wrappedValue
    }

    var wrappedValue: Int {
        get { value }
        set {
            let clamped = min(max(newValue, range.lowerBound), range.upperBound)
            value = clamped
            wasClamped = clamped != newValue
        }
    }

    var projectedValue: Bool {
        return wasClamped
    }
}

// Keep every value ever assigned (including the initial one), newest last.
@propertyWrapper
struct Logged<Value> {
    private var value: Value
    private var history: [Value]

    init(wrappedValue: Value) {
        self.value = wrappedValue
        self.history = [wrappedValue]
    }

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            history.append(newValue)
        }
    }

    var projectedValue: [Value] {
        return history
    }
}

// Count how many times the value has been written (not counting initialization).
@propertyWrapper
struct Counted<Value> {
    private var value: Value
    private(set) var writeCount = 0

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            writeCount += 1
        }
    }

    var projectedValue: Int {
        return writeCount
    }
}

struct Thermostat {
    @Clamped(15...30) var temperature: Int = 20
    @Logged var mode: String = "off"
    @Counted var adjustments: Int = 0
}

func main() {
    var demo = Thermostat()
    demo.temperature = 35
    print("temperature \(demo.temperature), wasClamped \(demo.$temperature)")

    test("Clamped projects whether it clamped") {
        var t = Thermostat()

        t.temperature = 25
        assertEqual(t.temperature, 25, "25 is in range")
        assertFalse(t.$temperature, "25 was not clamped")

        t.temperature = 100
        assertEqual(t.temperature, 30, "100 clamps to 30")
        assertTrue(t.$temperature, "100 was clamped")

        t.temperature = -5
        assertEqual(t.temperature, 15, "-5 clamps to 15")
        assertTrue(t.$temperature, "-5 was clamped")
    }

    test("Logged keeps a history") {
        var t = Thermostat()

        assertEqual(t.mode, "off", "starts off")
        assertEqual(t.$mode, ["off"], "history starts with the initial value")

        t.mode = "heat"
        t.mode = "cool"

        assertEqual(t.mode, "cool", "latest value")
        assertEqual(t.$mode, ["off", "heat", "cool"], "full history newest last")
    }

    test("Counted counts writes") {
        var t = Thermostat()

        assertEqual(t.$adjustments, 0, "no writes yet")

        t.adjustments = 1
        t.adjustments = 2
        t.adjustments = 3

        assertEqual(t.adjustments, 3, "latest value")
        assertEqual(t.$adjustments, 3, "three writes")
    }

    runTests()
}
