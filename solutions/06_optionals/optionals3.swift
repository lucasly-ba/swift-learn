// optionals3.swift
//
// Optional chaining allows you to access properties and methods on optionals.
// If any link in the chain is nil, the whole expression returns nil.
//
// Fix the optional chaining to make the tests pass.

struct Person {
    var name: String
    var address: Address?
}

struct Address {
    var street: String
    var city: String
    var zipCode: String?
}

func getPersonInfo() -> (street: String?, city: String?, zip: String?) {
    let person1: Person? = Person(name: "Alice",
                                  address: Address(street: "123 Main St",
                                                 city: "Boston",
                                                 zipCode: "02101"))
    let person2: Person? = Person(name: "Bob", address: nil)
    let person3: Person? = nil

    // person2 has no address and person3 is nil, so chaining through them is nil.
    _ = person2
    _ = person3

    let street = person1?.address?.street

    let city = person1?.address?.city

    let zip = person1?.address?.zipCode

    return (street, city, zip)
}

func transformOptionals() -> (uppercased: String?, count: Int?, firstChar: Character?) {
    let text: String? = "hello"
    let empty: String? = ""
    let nilText: String? = nil
    _ = nilText

    let uppercased = text?.uppercased()

    let count = empty?.count

    let firstChar = text?.first

    return (uppercased, count, firstChar)
}

func main() {
    let p = getPersonInfo()
    print("street \(p.street ?? "?"), city \(p.city ?? "?"), zip \(p.zip ?? "?")")

    test("Optional chaining with structs") {
        let result = getPersonInfo()
        assertEqual(result.street, "123 Main St", "Should get street via chaining")
        assertEqual(result.city, "Boston", "Should get city from person1")
        assertEqual(result.zip, "02101", "Should get nested optional zipCode")
    }

    test("Optional chaining with methods") {
        let result = transformOptionals()
        assertEqual(result.uppercased, "HELLO", "Should uppercase the text")
        assertEqual(result.count, 0, "Empty string has count 0")
        assertEqual(result.firstChar, "h", "First character of 'hello'")
    }

    runTests()
}
