// init4.swift
//
// A required initializer must be implemented by every subclass. This lets a
// base class guarantee an initializer exists all the way down the hierarchy.
//
// Fix the subclass so it provides the required initializer.

class Shape {
    let name: String

    required init(name: String) {
        self.name = name
    }
}

class Circle: Shape {
    let radius: Double

    init(radius: Double) {
        self.radius = radius
        super.init(name: "Circle")
    }

    // TODO: Shape declares `required init(name:)`, so Circle must implement it
    // too. Provide it, defaulting the radius to 1.0 and calling super.
}

func test() {
    let c = Circle(radius: 5)
    assertEqual(c.radius, 5, "the normal initializer works")
    assertEqual(c.name, "Circle", "name is set through super.init")

    let d = Circle(name: "Circle")
    assertEqual(d.radius, 1.0, "the required initializer defaults radius to 1.0")
}

func main() {
    test()
    runTests()
}
