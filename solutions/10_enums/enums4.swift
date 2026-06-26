// enums4.swift
//
// Enums can be recursive and conform to protocols like CaseIterable.
// They're great for modeling tree-like data structures.
//
// Fix the recursive enum and protocol conformance to make the tests pass.

enum Suit: CaseIterable {
    case hearts, diamonds, clubs, spades

    var symbol: String {
        switch self {
        case .hearts: return "♥️"
        case .diamonds: return "♦️"
        case .clubs: return "♣️"
        case .spades: return "♠️"
        }
    }
}

indirect enum ArithmeticExpression {
    case number(Int)
    case addition(ArithmeticExpression, ArithmeticExpression)
    case multiplication(ArithmeticExpression, ArithmeticExpression)

    func evaluate() -> Int {
        switch self {
        case .number(let value):
            return value
        case .addition(let left, let right):
            return left.evaluate() + right.evaluate()
        case .multiplication(let left, let right):
            return left.evaluate() * right.evaluate()
        }
    }
}

indirect enum LinkedList<T> {
    case empty
    case node(value: T, next: LinkedList<T>)

    func count() -> Int {
        switch self {
        case .empty:
            return 0
        case .node(_, let next):
            return 1 + next.count()
        }
    }

    func toArray() -> [T] {
        switch self {
        case .empty:
            return []
        case .node(let value, let next):
            return [value] + next.toArray()
        }
    }
}

func main() {
    let expr = ArithmeticExpression.multiplication(.addition(.number(5), .number(4)), .number(2))
    print("(5 + 4) * 2 = \(expr.evaluate()), \(Suit.allCases.count) suits")

    test("CaseIterable protocol") {
        let allSuits = Suit.allCases
        assertEqual(allSuits.count, 4, "Four suits")
        assertEqual(allSuits.map { $0.symbol }, ["♥️", "♦️", "♣️", "♠️"],
                   "All suit symbols")
    }

    test("Recursive enum evaluation") {
        // (5 + 4) * 2
        let five = ArithmeticExpression.number(5)
        let four = ArithmeticExpression.number(4)
        let sum = ArithmeticExpression.addition(five, four)
        let two = ArithmeticExpression.number(2)
        let product = ArithmeticExpression.multiplication(sum, two)

        assertEqual(product.evaluate(), 18, "(5 + 4) * 2 = 18")
    }

    test("Indirect enum for linked list") {
        let list: LinkedList<Int> = .node(
            value: 1,
            next: .node(
                value: 2,
                next: .node(
                    value: 3,
                    next: .empty
                )
            )
        )

        assertEqual(list.count(), 3, "List has 3 elements")
        assertEqual(list.toArray(), [1, 2, 3], "List converts to array")

        let empty: LinkedList<String> = .empty
        assertEqual(empty.count(), 0, "Empty list has 0 elements")
        assertEqual(empty.toArray(), [], "Empty list converts to empty array")
    }

    runTests()
}
