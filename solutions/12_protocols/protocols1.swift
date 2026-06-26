// protocols1.swift
//
// Protocols define requirements that conforming types must implement.
// They're like contracts or interfaces in other languages.
//
// Fix the protocol definitions and conformance to make the tests pass.

protocol Describable {
    var description: String { get }
}

protocol Greetable {
    func greet() -> String
}

struct Book: Describable {
    let title: String
    let author: String
    let pages: Int

    var description: String {
        return "\(title) by \(author) (\(pages) pages)"
    }
}

class Person: Describable, Greetable {
    let name: String
    let age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    var description: String {
        return "\(name), age \(age)"
    }

    func greet() -> String {
        return "Hello, I'm \(name)!"
    }
}

func printDescription(of item: Describable) {
    print(item.description)
}

func main() {
    let book = Book(title: "1984", author: "George Orwell", pages: 328)
    print(book.description)

    test("Protocol conformance") {
        let book = Book(title: "1984", author: "George Orwell", pages: 328)
        assertEqual(book.description, "1984 by George Orwell (328 pages)",
                   "Book description")

        let person = Person(name: "Alice", age: 30)
        assertEqual(person.description, "Alice, age 30",
                   "Person description")
        assertEqual(person.greet(), "Hello, I'm Alice!",
                   "Person greeting")
    }

    test("Protocol as type") {
        let describables: [Describable] = [
            Book(title: "Swift Guide", author: "Apple", pages: 500),
            Person(name: "Bob", age: 25)
        ]

        let descriptions = describables.map { $0.description }
        assertEqual(descriptions.count, 2, "Two describable items")
        assertTrue(descriptions[0].contains("Swift Guide"), "Book in array")
        assertTrue(descriptions[1].contains("Bob"), "Person in array")
    }

    runTests()
}
