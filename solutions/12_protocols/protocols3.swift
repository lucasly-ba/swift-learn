// protocols3.swift
//
// Protocols can be composed and used with associated types.
// This enables powerful generic programming patterns.
//
// Fix the protocol composition and associated types to make the tests pass.

protocol Named {
    var name: String { get }
}

protocol Aged {
    var age: Int { get }
}

typealias Person = Named & Aged

protocol Container {
    associatedtype Item
    var count: Int { get }
    mutating func add(_ item: Item)
    func getAll() -> [Item]
}

struct Stack<T>: Container {
    private var items: [T] = []

    var count: Int {
        return items.count
    }

    mutating func add(_ item: T) {
        items.append(item)
    }

    func getAll() -> [T] {
        return items
    }

    mutating func pop() -> T? {
        return items.popLast()
    }
}

func describe(person: Person) -> String {
    return "\(person.name) is \(person.age) years old"
}

struct Employee: Named, Aged {
    let name: String
    let age: Int
    let id: String
}

func main() {
    let employee = Employee(name: "John", age: 35, id: "E123")
    print(describe(person: employee))

    test("Protocol composition") {
        let employee = Employee(name: "John", age: 35, id: "E123")
        let description = describe(person: employee)
        assertEqual(description, "John is 35 years old", "Description with composition")
    }

    test("Associated types") {
        var intStack = Stack<Int>()
        intStack.add(10)
        intStack.add(20)
        intStack.add(30)

        assertEqual(intStack.count, 3, "Stack has 3 items")
        assertEqual(intStack.getAll(), [10, 20, 30], "All items in order")

        let popped = intStack.pop()
        assertEqual(popped, 30, "Popped last item")
        assertEqual(intStack.count, 2, "Stack has 2 items after pop")
    }

    test("Container with strings") {
        var stringStack = Stack<String>()
        stringStack.add("Hello")
        stringStack.add("World")

        assertEqual(stringStack.count, 2, "String stack count")
        assertEqual(stringStack.getAll(), ["Hello", "World"], "String stack contents")
    }

    runTests()
}
