// codable2.swift
//
// Writing Codable by hand. When the JSON does not line up with your stored
// properties, you implement init(from:) and encode(to:) yourself, using a
// keyed or single-value container.
//
// Fix the custom Codable conformances to make the tests pass.

import Foundation

// Stored in Celsius, but the JSON represents the temperature in Fahrenheit.
struct Temperature: Codable {
    let celsius: Double

    enum CodingKeys: String, CodingKey {
        case fahrenheit
    }

    init(celsius: Double) {
        self.celsius = celsius
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fahrenheit = try container.decode(Double.self, forKey: .fahrenheit)
        self.celsius = (fahrenheit - 32) / 1.8
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(celsius * 1.8 + 32, forKey: .fahrenheit)
    }
}

// Stored as red/green/blue (0...255), but the JSON is a "#RRGGBB" hex string.
struct RGBColor: Codable {
    let red: Int
    let green: Int
    let blue: Int

    enum CodingKeys: String, CodingKey {
        case hex
    }

    init(red: Int, green: Int, blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hex = try container.decode(String.self, forKey: .hex)
        let digits = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex

        func component(_ start: Int) -> Int {
            let lower = digits.index(digits.startIndex, offsetBy: start)
            let upper = digits.index(lower, offsetBy: 2)
            return Int(digits[lower..<upper], radix: 16) ?? 0
        }

        self.red = component(0)
        self.green = component(2)
        self.blue = component(4)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let hex = String(format: "#%02X%02X%02X", red, green, blue)
        try container.encode(hex, forKey: .hex)
    }
}

// A thin wrapper around an Int that encodes as a bare number (single value).
struct UserID: Codable, Equatable {
    let value: Int

    init(_ value: Int) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(Int.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

func main() {
    let json = String(data: try! JSONEncoder().encode(Temperature(celsius: 100)), encoding: .utf8)!
    print("100C encodes to \(json)")

    test("Fahrenheit <-> Celsius") {
        let data = """
        {"fahrenheit": 212}
        """.data(using: .utf8)!

        let temperature = try! JSONDecoder().decode(Temperature.self, from: data)
        assertEqual(temperature.celsius, 100, "212F decodes to 100C")

        let encoded = try! JSONEncoder().encode(Temperature(celsius: 0))
        let string = String(data: encoded, encoding: .utf8)!
        assertEqual(string, "{\"fahrenheit\":32}", "0C encodes to 32F")
    }

    test("Hex color") {
        let data = """
        {"hex": "#FF7F00"}
        """.data(using: .utf8)!

        let color = try! JSONDecoder().decode(RGBColor.self, from: data)
        assertEqual(color.red, 255, "Red component")
        assertEqual(color.green, 127, "Green component")
        assertEqual(color.blue, 0, "Blue component")

        let encoded = try! JSONEncoder().encode(RGBColor(red: 0, green: 128, blue: 255))
        let string = String(data: encoded, encoding: .utf8)!
        assertEqual(string, "{\"hex\":\"#0080FF\"}", "Encodes back to hex")
    }

    test("Single value wrapper") {
        let data = "42".data(using: .utf8)!
        let id = try! JSONDecoder().decode(UserID.self, from: data)
        assertEqual(id, UserID(42), "Decodes a bare number")

        let encoded = try! JSONEncoder().encode(UserID(7))
        let string = String(data: encoded, encoding: .utf8)!
        assertEqual(string, "7", "Encodes as a bare number")
    }

    runTests()
}
