// codable3.swift
//
// Nested containers and key strategies. A flat Swift type can map to a nested
// JSON shape with nestedContainer, and a JSONDecoder's keyDecodingStrategy can
// translate snake_case keys for you.
//
// Fix the Codable types to make the tests pass.

import Foundation

// A flat type that maps to JSON with a nested "address" object.
struct Person: Codable {
    let name: String
    let age: Int
    let street: String
    let city: String

    enum CodingKeys: String, CodingKey {
        case name, age, address
    }

    enum AddressKeys: String, CodingKey {
        case street, city
    }

    init(name: String, age: Int, street: String, city: String) {
        self.name = name
        self.age = age
        self.street = street
        self.city = city
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)

        let address = try container.nestedContainer(keyedBy: AddressKeys.self, forKey: .address)
        street = try address.decode(String.self, forKey: .street)
        city = try address.decode(String.self, forKey: .city)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)

        var address = container.nestedContainer(keyedBy: AddressKeys.self, forKey: .address)
        try address.encode(street, forKey: .street)
        try address.encode(city, forKey: .city)
    }
}

// camelCase properties; the JSON uses snake_case and convertFromSnakeCase.
struct Article: Codable {
    let title: String
    let authorName: String
    let wordCount: Int
}

// Nested arrays of Codable values.
struct LineItem: Codable {
    let product: String
    let quantity: Int
}

struct Order: Codable {
    let id: Int
    let items: [LineItem]
}

func main() {
    let json = """
    {"name": "Ada", "age": 30, "address": {"street": "1 Main St", "city": "London"}}
    """.data(using: .utf8)!
    let person = try! JSONDecoder().decode(Person.self, from: json)
    print("decoded \(person.name) from \(person.city)")

    test("Nested container flattening") {
        let data = """
        {
            "name": "Ada",
            "age": 30,
            "address": {"street": "1 Main St", "city": "London"}
        }
        """.data(using: .utf8)!

        let person = try! JSONDecoder().decode(Person.self, from: data)
        assertEqual(person.name, "Ada", "Name")
        assertEqual(person.age, 30, "Age")
        assertEqual(person.street, "1 Main St", "Street from nested object")
        assertEqual(person.city, "London", "City from nested object")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let encoded = String(data: try! encoder.encode(person), encoding: .utf8)!
        assertTrue(encoded.contains("\"address\":{"), "Re-encodes as a nested object")
        assertTrue(encoded.contains("\"street\":\"1 Main St\""), "Street inside address")
    }

    test("Snake case key strategy") {
        let data = """
        {"title": "Codable", "author_name": "Jane Doe", "word_count": 1200}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let article = try! decoder.decode(Article.self, from: data)
        assertEqual(article.title, "Codable", "Title")
        assertEqual(article.authorName, "Jane Doe", "author_name -> authorName")
        assertEqual(article.wordCount, 1200, "word_count -> wordCount")
    }

    test("Nested arrays") {
        let data = """
        {
            "id": 7,
            "items": [
                {"product": "Book", "quantity": 2},
                {"product": "Pen", "quantity": 5}
            ]
        }
        """.data(using: .utf8)!

        let order = try! JSONDecoder().decode(Order.self, from: data)
        assertEqual(order.id, 7, "Order id")
        assertEqual(order.items.count, 2, "Two line items")
        assertEqual(order.items[0].product, "Book", "First product")
        assertEqual(order.items[1].quantity, 5, "Second quantity")
    }

    runTests()
}
