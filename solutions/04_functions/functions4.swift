// functions4.swift
//
// Functions can modify their parameters using `inout`.
// This allows the function to change the original value passed in.
// The & symbol is used when calling the function with an inout parameter.
//
// Fix the functions to use inout parameters correctly.

func swap(a: inout Int, b: inout Int) {
    let temp = a
    a = b
    b = temp
}

func removeNegatives(from numbers: inout [Int]) {
    numbers = numbers.filter { $0 >= 0 }
}

func incrementCounter(counter: inout Int, by amount: Int = 1) {
    counter += amount
}

func main() {
    var x = 10
    var y = 20
    swap(a: &x, b: &y)
    print("after swap x \(x), y \(y)")

    test("Swap function exchanges values") {
        var x = 10
        var y = 20
        swap(a: &x, b: &y)
        assertEqual(x, 20, "x should now be 20")
        assertEqual(y, 10, "y should now be 10")
    }

    test("Remove negatives modifies array") {
        var numbers = [1, -2, 3, -4, 5]
        removeNegatives(from: &numbers)
        assertEqual(numbers, [1, 3, 5], "Negatives should be removed")

        var empty: [Int] = []
        removeNegatives(from: &empty)
        assertEqual(empty, [], "Empty array remains empty")
    }

    test("Increment counter modifies value") {
        var count = 0
        incrementCounter(counter: &count)
        assertEqual(count, 1, "Should increment by default amount")

        incrementCounter(counter: &count, by: 5)
        assertEqual(count, 6, "Should increment by specified amount")
    }

    runTests()
}
