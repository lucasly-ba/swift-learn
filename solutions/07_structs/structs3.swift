// structs3.swift
//
// Structs can have computed properties that calculate values on demand.
// They can also have property observers to respond to changes.
//
// Fix the computed properties and observers to make the tests pass.

struct Temperature {
    // Stored property in Celsius
    var celsius: Double {
        didSet {
            print("Temperature changed to \(celsius)°C")
        }
    }

    var fahrenheit: Double {
        get {
            return celsius * 1.8 + 32
        }
        set {
            celsius = (newValue - 32) / 1.8
        }
    }

    var kelvin: Double {
        return celsius + 273.15
    }

    var isFreezing: Bool {
        return celsius <= 0
    }
}

struct Circle {
    var radius: Double {
        willSet {
            print("Radius will change to \(newValue)")
        }
    }

    var area: Double {
        return 3.14159 * radius * radius
    }

    var diameter: Double {
        return radius * 2
    }
}

func main() {
    let temp = Temperature(celsius: 25)
    print("25C = \(temp.fahrenheit)F, \(temp.kelvin)K")

    test("Temperature conversions") {
        var temp = Temperature(celsius: 25)

        assertEqual(temp.fahrenheit, 77.0, "25°C = 77°F")
        assertEqual(temp.kelvin, 298.15, "25°C = 298.15K")
        assertFalse(temp.isFreezing, "25°C is not freezing")

        temp.fahrenheit = 32  // Sets celsius to 0
        assertEqual(temp.celsius, 0.0, "32°F = 0°C")
        assertTrue(temp.isFreezing, "0°C is freezing point")
    }

    test("Circle properties") {
        var circle = Circle(radius: 5)

        assertEqual(circle.area, 78.53975, accuracy: 0.00001, "Area of circle with radius 5")
        assertEqual(circle.diameter, 10.0, "Diameter should be 2 * radius")

        circle.radius = 10  // Should trigger willSet
        assertEqual(circle.diameter, 20.0, "New diameter after radius change")
    }

    runTests()
}

/// Helper for comparing doubles with accuracy
func assertEqual(_ actual: Double, _ expected: Double, accuracy: Double, _ message: String) {
    assertTrue(abs(actual - expected) < accuracy,
               "\(message): expected \(expected), got \(actual)")
}
