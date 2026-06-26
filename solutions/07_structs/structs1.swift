// structs1.swift
//
// Structs are value types that encapsulate data and functionality.
// They're one of the most important building blocks in Swift.
//
// Fix the struct definition and usage to make the tests pass.

struct Point {
    var x: Int
    var y: Int
}

struct Person {
    var name: String
    var age: Int
}

func createStructs() -> (point: Point, person: Person) {
    let point = Point(x: 10, y: 20)

    let person = Person(name: "Alice", age: 30)

    return (point, person)
}

func main() {
    let s = createStructs()
    print("point (\(s.point.x), \(s.point.y)), person \(s.person.name) \(s.person.age)")

    test("Struct creation and properties") {
        let (point, person) = createStructs()

        assertEqual(point.x, 10, "Point x should be 10")
        assertEqual(point.y, 20, "Point y should be 20")
        assertEqual(person.name, "Alice", "Person name should be Alice")
        assertEqual(person.age, 30, "Person age should be 30")
    }

    test("Structs are value types") {
        var p1 = Point(x: 5, y: 10)
        var p2 = p1  // This creates a copy
        p2.x = 15

        assertEqual(p1.x, 5, "Original point should not change")
        assertEqual(p2.x, 15, "Copy should have new value")
    }

    runTests()
}
