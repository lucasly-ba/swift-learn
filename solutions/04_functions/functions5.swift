// functions5.swift
//
// Functions are first-class types in Swift.
// They can be assigned to variables, passed as parameters, and returned from functions.
//
// Fix the function types and implementations.

let addFunction: (Int, Int) -> Int = { (a: Int, b: Int) -> Int in
    return a + b
}

func applyOperation(_ operation: (Int, Int) -> Int, to a: Int, and b: Int) -> Int {
    return operation(a, b)
}

func getOperation(named name: String) -> (Int, Int) -> Int {
    switch name {
    case "add":
        return { $0 + $1 }
    case "multiply":
        return { $0 * $1 }
    default:
        return { _, _ in 0 }
    }
}

func main() {
    print("add \(addFunction(3, 5)), apply \(applyOperation(addFunction, to: 7, and: 3)), op \(getOperation(named: "multiply")(4, 6))")

    test("Function variable works correctly") {
        assertEqual(addFunction(3, 5), 8, "3 + 5 = 8")
        assertEqual(addFunction(10, -3), 7, "10 + (-3) = 7")
    }

    test("Apply operation with function parameter") {
        let multiply = { (x: Int, y: Int) -> Int in x * y }
        assertEqual(applyOperation(multiply, to: 4, and: 5), 20, "4 * 5 = 20")
        assertEqual(applyOperation(addFunction, to: 7, and: 3), 10, "7 + 3 = 10")
    }

    test("Get operation returns correct function") {
        let add = getOperation(named: "add")
        assertEqual(add(2, 3), 5, "Add operation: 2 + 3 = 5")

        let mult = getOperation(named: "multiply")
        assertEqual(mult(4, 6), 24, "Multiply operation: 4 * 6 = 24")

        let unknown = getOperation(named: "unknown")
        assertEqual(unknown(10, 20), 0, "Unknown operation returns 0")
    }

    runTests()
}
