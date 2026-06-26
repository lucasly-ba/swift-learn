// loops2.swift
//
// `while` loops continue executing as long as a condition is true.
// Be careful to avoid infinite loops!
//
// Fix the while loops to make the tests pass.

func findFirstMultiple(of factor: Int, startingFrom start: Int) -> Int {
    var current = start

    while current % factor != 0 {
        current += 1
    }

    return current
}

func collectDigits(of number: Int) -> [Int] {
    var digits: [Int] = []
    var n = number

    while n > 0 {
        let digit = n % 10
        digits.insert(digit, at: 0)
        n = n / 10
    }

    return digits
}

func main() {
    print("first multiple of 3 from 10 = \(findFirstMultiple(of: 3, startingFrom: 10)), digits of 123 = \(collectDigits(of: 123))")

    test("Find first multiple correctly") {
        assertEqual(findFirstMultiple(of: 3, startingFrom: 10), 12, "First multiple of 3 from 10 is 12")
        assertEqual(findFirstMultiple(of: 5, startingFrom: 12), 15, "First multiple of 5 from 12 is 15")
        assertEqual(findFirstMultiple(of: 7, startingFrom: 21), 21, "21 is already a multiple of 7")
    }

    test("Collect digits correctly") {
        assertEqual(collectDigits(of: 123), [1, 2, 3], "Digits of 123")
        assertEqual(collectDigits(of: 9), [9], "Single digit number")
        assertEqual(collectDigits(of: 5678), [5, 6, 7, 8], "Digits of 5678")
        assertEqual(collectDigits(of: 1000), [1, 0, 0, 0], "Digits with zeros")
    }

    runTests()
}
