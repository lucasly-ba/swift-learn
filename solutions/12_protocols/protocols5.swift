// protocols5.swift
//
// Conforming to Equatable lets you compare values with ==. Conforming to
// Hashable (which also requires Equatable) lets you store values in a Set or
// use them as dictionary keys. Classes do not get these for free.
//
// Fix the class so it conforms to Equatable and Hashable.

class Point: Hashable {
    let x: Int
    let y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

func test() {
    assertEqual(Point(x: 1, y: 2), Point(x: 1, y: 2), "equal points compare equal")
    assertNotEqual(Point(x: 1, y: 2), Point(x: 3, y: 4), "different points are not equal")

    var seen: Set<Point> = []
    seen.insert(Point(x: 1, y: 2))
    seen.insert(Point(x: 1, y: 2))
    seen.insert(Point(x: 3, y: 4))
    assertEqual(seen.count, 2, "the Set removes the duplicate point")
}

func main() {
    print("equal points? \(Point(x: 1, y: 2) == Point(x: 1, y: 2))")

    test()
    runTests()
}
