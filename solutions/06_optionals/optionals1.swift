// optionals1.swift
//
// Optionals represent values that might be missing (nil).
// They're Swift's way of handling the absence of a value safely.
//
// Fix the optional declarations and unwrapping to make the tests pass.

func optionalBasics() -> (name: String, age: String, city: String) {
    let name: String? = "Alice"
    let age: Int? = 25
    let city: String? = nil

    var unwrappedName = "Unknown"
    if let name = name {
        unwrappedName = name
    }

    let unwrappedAge = age!

    let unwrappedCity = city ?? "Unknown"

    return (unwrappedName, "Age: \(unwrappedAge)", unwrappedCity)
}

func findInArray() -> (found: Int, notFound: Int) {
    let numbers = [10, 20, 30, 40, 50]

    let index1 = numbers.firstIndex(of: 30)
    let foundValue = numbers[index1!]

    let index2 = numbers.firstIndex(of: 99)
    let notFoundValue = index2 ?? -1

    return (foundValue, notFoundValue)
}

func main() {
    let r = optionalBasics()
    print("\(r.name), \(r.age), \(r.city)")

    test("Optional basics") {
        let result = optionalBasics()
        assertEqual(result.name, "Alice", "Name should be unwrapped")
        assertEqual(result.age, "Age: 25", "Age should be force unwrapped")
        assertEqual(result.city, "Unknown", "City should use default value")
    }

    test("Array optional returns") {
        let result = findInArray()
        assertEqual(result.found, 30, "Should find value 30")
        assertEqual(result.notFound, -1, "Should return -1 when not found")
    }

    runTests()
}
