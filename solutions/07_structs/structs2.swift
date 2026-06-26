// structs2.swift
//
// Structs can have methods that provide functionality.
// Methods can be instance methods or static methods.
//
// Fix the struct methods to make the tests pass.

struct Rectangle {
    var width: Double
    var height: Double

    func area() -> Double {
        return width * height
    }

    func perimeter() -> Double {
        return 2 * (width + height)
    }

    func isSquare() -> Bool {
        return width == height
    }

    static func square(side: Double) -> Rectangle {
        return Rectangle(width: side, height: side)
    }
}

func testRectangle() -> (area: Double, perimeter: Double, isSquare: Bool, square: Rectangle) {
    let rect = Rectangle(width: 10, height: 5)

    let area = rect.area()
    let perimeter = rect.perimeter()
    let isSquare = rect.isSquare()
    let square = Rectangle.square(side: 7)

    return (area, perimeter, isSquare, square)
}

func main() {
    let result = testRectangle()
    print("area \(result.area), perimeter \(result.perimeter), isSquare \(result.isSquare)")

    test("Rectangle methods") {
        let result = testRectangle()

        assertEqual(result.area, 50.0, "Area should be 50 (10 * 5)")
        assertEqual(result.perimeter, 30.0, "Perimeter should be 30 (2 * (10 + 5))")
        assertFalse(result.isSquare, "10x5 rectangle is not a square")
        assertEqual(result.square.width, 7.0, "Square width should be 7")
        assertEqual(result.square.height, 7.0, "Square height should be 7")
    }

    test("Square check") {
        let square = Rectangle(width: 5, height: 5)
        assertTrue(square.isSquare(), "5x5 rectangle is a square")
    }

    runTests()
}
