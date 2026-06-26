// enums3.swift
//
// Enums can have methods, computed properties, and conform to protocols.
// They're full-fledged types in Swift.
//
// Fix the enum methods and properties to make the tests pass.

enum Planet: Int {
    case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune

    var name: String {
        switch self {
        case .mercury: return "Mercury"
        case .venus: return "Venus"
        case .earth: return "Earth"
        case .mars: return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn: return "Saturn"
        case .uranus: return "Uranus"
        case .neptune: return "Neptune"
        }
    }

    var isInner: Bool {
        // Mercury through Mars have raw values 1...4.
        return rawValue <= 4
    }

    func distanceFromSun() -> Double {
        switch self {
        case .mercury: return 0.39
        case .venus: return 0.72
        case .earth: return 1.0
        case .mars: return 1.52
        case .jupiter: return 5.20
        case .saturn: return 9.54
        case .uranus: return 19.19
        case .neptune: return 30.07
        }
    }

    static var allCases: [Planet] {
        return [.mercury, .venus, .earth, .mars, .jupiter, .saturn, .uranus, .neptune]
    }
}

enum Calculator {
    case number(Double)
    case operation(String)

    func evaluate(with value: Double) -> Double? {
        switch self {
        case .number(let n):
            return n
        case .operation(let op):
            // Apply the operation against a running total of 0.
            switch op {
            case "+": return 0 + value
            case "-": return 0 - value
            case "*": return 0 * value
            case "/": return value == 0 ? nil : 0 / value
            default: return nil
            }
        }
    }

    static func add(_ value: Double) -> Calculator {
        return .operation("+\(Int(value))")
    }
}

func main() {
    print("earth \(Planet.earth.name) at \(Planet.earth.distanceFromSun()) AU, \(Planet.allCases.count) planets")

    test("Enum properties") {
        let earth = Planet.earth
        assertEqual(earth.name, "Earth", "Planet name")
        assertTrue(earth.isInner, "Earth is inner planet")
        assertEqual(earth.distanceFromSun(), 1.0, "Earth is 1 AU from sun")

        let jupiter = Planet.jupiter
        assertEqual(jupiter.name, "Jupiter", "Jupiter name")
        assertFalse(jupiter.isInner, "Jupiter is outer planet")
        assertEqual(jupiter.distanceFromSun(), 5.20, "Jupiter distance")
    }

    test("Static enum properties") {
        let allPlanets = Planet.allCases
        assertEqual(allPlanets.count, 8, "8 planets")
        assertEqual(allPlanets.first, .mercury, "First planet")
        assertEqual(allPlanets.last, .neptune, "Last planet")
    }

    test("Enum methods") {
        let num = Calculator.number(10)
        assertEqual(num.evaluate(with: 5), 10.0, "Number returns itself")

        let add = Calculator.operation("+")
        assertEqual(add.evaluate(with: 5), 5.0, "5 + current = 5")

        let multiply = Calculator.operation("*")
        assertEqual(multiply.evaluate(with: 3), 0.0, "3 * current = 0")
    }

    test("Static factory methods") {
        let addFive = Calculator.add(5)

        switch addFive {
        case .operation(let op):
            assertEqual(op, "+5", "Should store operation with value")
        default:
            assertFalse(true, "Should be operation")
        }
    }

    runTests()
}
