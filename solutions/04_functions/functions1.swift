// functions1.swift
//
// Functions are self-contained chunks of code that perform a specific task.
// In Swift, functions are declared with the `func` keyword.
//
// Fix the function declarations to make the tests pass.

func greet(name: String) -> String {
    return "Hello, \(name)!"
}

func add(_ a: Int, _ b: Int) -> Int {
    return a + b
}

func multiply(x: Int, y: Int) -> Int {
    return x * y
}

func main() {
    print("greet \(greet(name: "Alice")), add \(add(2, 3)), multiply \(multiply(x: 4, y: 5))")

    test("Greeting function works correctly") {
        assertEqual(greet(name: "Alice"), "Hello, Alice!", "Should greet Alice")
        assertEqual(greet(name: "Bob"), "Hello, Bob!", "Should greet Bob")
    }

    test("Addition function works correctly") {
        assertEqual(add(5, 3), 8, "5 + 3 = 8")
        assertEqual(add(10, -5), 5, "10 + (-5) = 5")
        assertEqual(add(0, 0), 0, "0 + 0 = 0")
    }

    test("Multiplication function works correctly") {
        assertEqual(multiply(x: 4, y: 5), 20, "4 * 5 = 20")
        assertEqual(multiply(x: -3, y: 2), -6, "-3 * 2 = -6")
        assertEqual(multiply(x: 0, y: 100), 0, "0 * 100 = 0")
    }

    runTests()
}
