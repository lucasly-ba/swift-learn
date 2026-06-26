// advanced_types1.swift
//
// Type aliases, nested types, and associated types.
// Building sophisticated type relationships in Swift.
//
// Fix the type definitions to make the tests pass.

typealias UserID = Int
typealias Completion = (Result<String>) -> Void
typealias JSONDictionary = [String: Any]

struct Database {
    class Connection {
        var isConnected = false

        func connect() {
            isConnected = true
        }
    }

    enum Error {
        case connectionFailed
        case queryFailed(String)
        case timeout
    }

    struct Query {
        let table: String
        var conditions: [String] = []

        func filter(_ condition: String) -> Query {
            var copy = self
            copy.conditions.append(condition)
            return copy
        }
    }
}

protocol Container {
    associatedtype Item

    var count: Int { get }
    mutating func append(_ item: Item)
    func item(at index: Int) -> Item?
}

struct Stack<Element>: Container {
    private var items: [Element] = []

    var count: Int {
        return items.count
    }

    mutating func append(_ item: Element) {
        items.append(item)
    }

    func item(at index: Int) -> Element? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }

    mutating func push(_ item: Element) {
        append(item)
    }

    mutating func pop() -> Element? {
        return items.popLast()
    }
}

indirect enum Expression {
    case number(Int)
    case addition(Expression, Expression)
    case multiplication(Expression, Expression)

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

struct Pair<T: Equatable, U> {
    let first: T
    let second: U

    func hasEqualFirst(_ other: Pair<T, U>) -> Bool {
        return first == other.first
    }
}

protocol Named {
    var name: String { get }
}

protocol Aged {
    var age: Int { get }
}

func describe(person: Named & Aged) -> String {
    return "\(person.name) is \(person.age) years old"
}

func main() {
    let query = Database.Query(table: "users").filter("a").filter("b")
    print("query conditions \(query.conditions.count), 5 + 3 = \(Expression.addition(.number(5), .number(3)).evaluate())")

    test("Type aliases") {
        let userID: UserID = 123
        assertEqual(userID, 123, "UserID should be Int")

        let completion: Completion = { result in
            switch result {
            case .success(let value):
                assertEqual(value, "Done", "Success value")
            case .failure:
                assertFalse(true, "Should not fail")
            }
        }

        completion(.success("Done"))

        let json: JSONDictionary = ["name": "John", "age": 25, "active": true]
        assertEqual(json["age"] as? Int, 25, "Should support Any values")
    }

    test("Nested types") {
        let db = Database()
        _ = db
        let connection = Database.Connection()

        assertFalse(connection.isConnected, "Initially disconnected")
        connection.connect()
        assertTrue(connection.isConnected, "Should be connected")

        let error = Database.Error.queryFailed("Invalid syntax")
        if case .queryFailed(let message) = error {
            assertEqual(message, "Invalid syntax", "Error message")
        }

        let query = Database.Query(table: "users")
            .filter("age > 18")
            .filter("active = true")

        assertEqual(query.conditions.count, 2, "Should have 2 conditions")
    }

    test("Container protocol") {
        var stack = Stack<String>()
        stack.append("First")
        stack.append("Second")
        stack.push("Third")

        assertEqual(stack.count, 3, "Should have 3 items")
        assertEqual(stack.item(at: 1), "Second", "Middle item")
        assertEqual(stack.pop(), "Third", "Pop last item")
        assertEqual(stack.count, 2, "Should have 2 items after pop")
    }

    test("Recursive enum") {
        let expr = Expression.addition(
            .number(5),
            .multiplication(
                .number(3),
                .number(4)
            )
        )

        assertEqual(expr.evaluate(), 17, "5 + (3 * 4) = 17")

        let complex = Expression.multiplication(
            .addition(.number(2), .number(3)),
            .addition(.number(4), .number(6))
        )

        assertEqual(complex.evaluate(), 50, "(2 + 3) * (4 + 6) = 50")
    }

    test("Generic constraints") {
        let pair1 = Pair(first: "Hello", second: 42)
        let pair2 = Pair(first: "Hello", second: 99)
        let pair3 = Pair(first: "World", second: 42)

        assertTrue(pair1.hasEqualFirst(pair2), "Same first value")
        assertFalse(pair1.hasEqualFirst(pair3), "Different first value")
    }

    test("Protocol composition") {
        struct Person: Named, Aged {
            let name: String
            let age: Int
        }

        let person = Person(name: "Alice", age: 30)
        let description = describe(person: person)

        assertEqual(description, "Alice is 30 years old", "Person description")
    }

    runTests()
}

// Result type for Completion
enum Result<T> {
    case success(T)
    case failure(Error)
}

// Error for Result
struct Error: Swift.Error {
    let message: String
}
