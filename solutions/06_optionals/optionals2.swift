// optionals2.swift
//
// Guard statements provide early exit when optionals are nil.
// They're perfect for validating preconditions at the start of a function.
//
// Fix the guard statements to make the tests pass.

func validateUser(name: String?, age: Int?, email: String?) -> String {
    guard let name = name else {
        return "Error: Name is required"
    }

    guard let age = age, let email = email else {
        return "Error: Age and email are required"
    }

    guard age >= 18 else {
        return "Error: Must be 18 or older"
    }

    // All validations passed
    return "Welcome \(name)! Confirmation sent to \(email)"
}

func processNumbers(_ numbers: [Int]?) -> Int {
    guard let numbers = numbers else {
        return 0
    }

    guard !numbers.isEmpty else {
        return 0
    }

    return numbers.reduce(0, +)
}

func main() {
    print("\(validateUser(name: "Charlie", age: 21, email: "charlie@example.com")), sum \(processNumbers([1, 2, 3, 4, 5]))")

    test("User validation with guard") {
        assertEqual(validateUser(name: nil, age: 25, email: "test@example.com"),
                   "Error: Name is required", "Should fail on nil name")
        assertEqual(validateUser(name: "Alice", age: nil, email: nil),
                   "Error: Age and email are required", "Should fail on nil age/email")
        assertEqual(validateUser(name: "Bob", age: 16, email: "bob@example.com"),
                   "Error: Must be 18 or older", "Should fail on underage")
        assertEqual(validateUser(name: "Charlie", age: 21, email: "charlie@example.com"),
                   "Welcome Charlie! Confirmation sent to charlie@example.com", "Should succeed")
    }

    test("Process optional array") {
        assertEqual(processNumbers(nil), 0, "Nil array returns 0")
        assertEqual(processNumbers([]), 0, "Empty array returns 0")
        assertEqual(processNumbers([1, 2, 3, 4, 5]), 15, "Sum of 1-5 is 15")
    }

    runTests()
}
