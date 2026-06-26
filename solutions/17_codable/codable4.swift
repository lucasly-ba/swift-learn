// codable4.swift
//
// Dates and Codable. A JSONDecoder's dateDecodingStrategy decides how a JSON
// value becomes a Date: a Unix timestamp, an ISO 8601 string, or a custom
// format you supply with a DateFormatter.
//
// Fix the date decoding to make the tests pass.

import Foundation

struct Event: Codable {
    let name: String
    let date: Date
}

// A formatter for the custom "dd/MM/yyyy" date format used by one of the feeds.
let dayMonthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

// Format a decoded Date back to yyyy-MM-dd (UTC) so the tests can check it.
func yearMonthDay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
}

// A .custom strategy reads the raw value and parses it however we like.
func customDateStrategy(_ decoder: Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    guard let date = formatter.date(from: string) else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Bad date")
    }
    return date
}

func main() {
    let data = """
    {"name": "Launch", "date": 1704067200}
    """.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    let event = try! decoder.decode(Event.self, from: data)
    print("unix date -> \(yearMonthDay(event.date))")

    test("Unix timestamp dates") {
        let data = """
        {"name": "Launch", "date": 1704067200}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        let event = try! decoder.decode(Event.self, from: data)
        assertEqual(event.name, "Launch", "Name decoded")
        assertEqual(yearMonthDay(event.date), "2024-01-01", "Timestamp decoded to date")
    }

    test("ISO 8601 dates") {
        let data = """
        {"name": "Meeting", "date": "2024-01-15T10:00:00Z"}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let event = try! decoder.decode(Event.self, from: data)
        assertEqual(yearMonthDay(event.date), "2024-01-15", "ISO 8601 decoded to date")
    }

    test("Custom format dates") {
        let data = """
        {"name": "Deadline", "date": "20/01/2024"}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dayMonthYearFormatter)

        let event = try! decoder.decode(Event.self, from: data)
        assertEqual(yearMonthDay(event.date), "2024-01-20", "dd/MM/yyyy decoded to date")
    }

    test("Custom decoding strategy") {
        // A .custom strategy reads the raw value and parses it however you like.
        let data = """
        {"name": "Release", "date": "2024-02-29"}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateStrategy)

        let event = try! decoder.decode(Event.self, from: data)
        assertEqual(yearMonthDay(event.date), "2024-02-29", "Custom strategy parsed the date")
    }

    runTests()
}
