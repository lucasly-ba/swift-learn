// advanced_types3.swift
//
// Phantom types, type-level programming, and compile-time guarantees.
// Using Swift's type system for advanced patterns.
//
// Fix the advanced type patterns to make the tests pass.

import Foundation

struct Distance<Unit> {
    let value: Double

    init(_ value: Double) {
        self.value = value
    }
}

// Phantom type markers
enum Meters {}
enum Kilometers {}
enum Miles {}

extension Distance {
    static func + (lhs: Distance, rhs: Distance) -> Distance {
        return Distance(lhs.value + rhs.value)
    }
}

struct Door<State> {
    private let id: String

    init(id: String) {
        self.id = id
    }
}

// States as phantom types
enum Open {}
enum Closed {}
enum Locked {}

extension Door where State == Closed {
    func open() -> Door<Open> {
        return Door<Open>(id: id)
    }

    func lock() -> Door<Locked> {
        return Door<Locked>(id: id)
    }
}

extension Door where State == Open {
    func close() -> Door<Closed> {
        return Door<Closed>(id: id)
    }
}

extension Door where State == Locked {
    func unlock() -> Door<Closed> {
        return Door<Closed>(id: id)
    }
}

struct RequestBuilder<State> {
    var url: String = ""
    var method: String = "GET"
    var headers: [String: String] = [:]
    var body: Data?
}

// Builder states
enum URLMissing {}
enum URLSet {}
enum Ready {}

extension RequestBuilder where State == URLMissing {
    func setURL(_ url: String) -> RequestBuilder<URLSet> {
        var builder = RequestBuilder<URLSet>()
        builder.url = url
        return builder
    }
}

extension RequestBuilder where State == URLSet {
    func setMethod(_ method: String) -> RequestBuilder<URLSet> {
        var builder = self
        builder.method = method
        return builder
    }

    func setHeader(_ key: String, value: String) -> RequestBuilder<URLSet> {
        var builder = self
        builder.headers[key] = value
        return builder
    }

    func build() -> RequestBuilder<Ready> {
        var builder = RequestBuilder<Ready>()
        builder.url = url
        builder.method = method
        builder.headers = headers
        builder.body = body
        return builder
    }
}

extension RequestBuilder where State == Ready {
    func send() -> String {
        return "\(method) \(url)"
    }
}

struct Vector<N> {
    let elements: [Double]

    init(_ elements: Double...) {
        self.elements = Array(elements)
    }
}

// Type-level numbers
struct Zero {}
struct Succ<N> {}
typealias One = Succ<Zero>
typealias Two = Succ<One>
typealias Three = Succ<Two>

extension Vector {
    func dot(_ other: Vector<Three>) -> Double {
        return zip(elements, other.elements).map { $0 * $1 }.reduce(0, +)
    }
}

protocol Witness {
    associatedtype Value
    static var value: Value { get }
}

struct IntWitness: Witness {
    static var value: Int { 42 }
}

struct StringWitness: Witness {
    static var value: String { "Hello" }
}

func getValue<W: Witness>(_ witness: W.Type) -> W.Value {
    return witness.value
}

func main() {
    let meters = Distance<Meters>(100)
    print("100m + 50m = \((meters + Distance<Meters>(50)).value)")

    test("Phantom types for units") {
        let meters = Distance<Meters>(100)
        let moreMeters = Distance<Meters>(50)

        let total = meters + moreMeters
        assertEqual(total.value, 150, "Added distances")

        let km: Distance<Kilometers> = meters.converted(to: Kilometers.self)
        assertEqual(km.value, 0.1, "100m = 0.1km")

        let miles: Distance<Miles> = km.converted(to: Miles.self)
        assertEqual(miles.value, 0.062137, "0.1km ≈ 0.062137 miles", accuracy: 0.000001)
    }

    test("State machine with phantom types") {
        let closedDoor = Door<Closed>(id: "front")
        let openDoor = closedDoor.open()
        let closedAgain = openDoor.close()
        let lockedDoor = closedAgain.lock()
        let unlockedDoor = lockedDoor.unlock()
        _ = unlockedDoor

        assertTrue(true, "State transitions enforced at compile time")
    }

    test("Type-safe builder") {
        let request = RequestBuilder<URLMissing>()
            .setURL("https://api.example.com/data")
            .setMethod("POST")
            .setHeader("Content-Type", value: "application/json")
            .setHeader("Authorization", value: "Bearer token")
            .build()

        let response = request.send()
        assertEqual(response, "POST https://api.example.com/data", "Request sent")
    }

    test("Type-level numbers") {
        let vec3a = Vector<Three>(1, 2, 3)
        let vec3b = Vector<Three>(4, 5, 6)

        let dotProduct = vec3a.dot(vec3b)
        assertEqual(dotProduct, 32, "1*4 + 2*5 + 3*6 = 32")
    }

    test("Witness types") {
        let intValue = getValue(IntWitness.self)
        assertEqual(intValue, 42, "Int witness value")

        let stringValue = getValue(StringWitness.self)
        assertEqual(stringValue, "Hello", "String witness value")

        let value: Int = getValue(IntWitness.self)
        assertEqual(value, 42, "Type inferred correctly")
    }

    test("Complex phantom type usage") {
        struct Temperature<Scale> {
            let value: Double
        }

        enum Celsius {}
        enum Fahrenheit {}

        let celsius = Temperature<Celsius>(value: 25)
        let fahrenheit = Temperature<Fahrenheit>(value: 77)
        _ = celsius
        _ = fahrenheit

        assertTrue(true, "Temperature scales type-safe")
    }

    runTests()
}

// Conversion implementations
extension Distance where Unit == Meters {
    func converted<ToUnit>(to unit: ToUnit.Type) -> Distance<ToUnit> {
        if unit == Kilometers.self {
            return Distance<ToUnit>(value / 1000)
        } else if unit == Miles.self {
            return Distance<ToUnit>(value / 1609.344)
        }
        return Distance<ToUnit>(value)
    }
}

extension Distance where Unit == Kilometers {
    func converted<ToUnit>(to unit: ToUnit.Type) -> Distance<ToUnit> {
        if unit == Meters.self {
            return Distance<ToUnit>(value * 1000)
        } else if unit == Miles.self {
            return Distance<ToUnit>(value * 0.621371)
        }
        return Distance<ToUnit>(value)
    }
}

// Approximate-equality assert helper used by the distance conversion test.
func assertEqual(_ actual: Double, _ expected: Double, _ message: String, accuracy: Double) {
    assertTrue(abs(actual - expected) <= accuracy, "\(message): expected \(expected), got \(actual)")
}
