// properties1.swift
//
// A stored property holds a value. A computed property has no storage of its
// own; it calculates its value each time it is read, from other properties.
//
// Fix the struct by adding a computed property.

struct Rectangle {
    let width: Double
    let height: Double

    // TODO: Add a computed property `area` of type Double that returns
    // width * height.
}

func test() {
    let r = Rectangle(width: 4, height: 5)
    assertEqual(r.area, 20, "area should be width * height")
}

func main() {
    test()
    runTests()
}
