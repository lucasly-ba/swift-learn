// enums2.swift
//
// Heads up: this exercise uses a generic type parameter T (the <T> below).
// You will learn generics in 14_generics. Here you only need to fill in the
// associated values, so you can treat T as "some type that gets decided later".
//
// Enums can have associated values that store additional information.
// This makes them powerful for modeling data with variations.
//
// Fix the enums with associated values to make the tests pass.

enum Result<T> {
    case success(T)
    case failure(String)
}

enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}

enum NetworkResponse {
    case success(Data, Int)
    case error(String)
    case timeout
}

// For this exercise, use a simple Data type
struct Data {
    let content: String
}

func createBarcode() -> Barcode {
    return Barcode.upc(8, 85909, 51226, 3)
}

func handleResponse(_ response: NetworkResponse) -> String {
    switch response {
    case .success(_, let statusCode):
        return "Success with \(statusCode)"
    case .error(let message):
        return "Error: \(message)"
    case .timeout:
        return "Request timed out"
    }
}

func processResult<T>(_ result: Result<T>) -> String {
    switch result {
    case .success(let value):
        return "Success: \(value)"
    case .failure(let message):
        return "Failed: \(message)"
    }
}

func main() {
    print("response: \(handleResponse(.success(Data(content: "Hi"), 200))), result: \(processResult(Result<Int>.success(42)))")

    test("Enums with associated values") {
        let barcode = createBarcode()

        switch barcode {
        case .upc(let a, let b, let c, let d):
            assertEqual(a, 8, "First UPC component")
            assertEqual(b, 85909, "Second UPC component")
            assertEqual(c, 51226, "Third UPC component")
            assertEqual(d, 3, "Fourth UPC component")
        default:
            assertFalse(true, "Should be UPC barcode")
        }
    }

    test("Pattern matching with associated values") {
        let successResponse = NetworkResponse.success(Data(content: "Hello"), 200)
        let errorResponse = NetworkResponse.error("Not found")
        let timeoutResponse = NetworkResponse.timeout

        assertEqual(handleResponse(successResponse), "Success with 200",
                   "Should include status code")
        assertEqual(handleResponse(errorResponse), "Error: Not found",
                   "Should include error message")
        assertEqual(handleResponse(timeoutResponse), "Request timed out",
                   "Timeout message")
    }

    test("Generic enum handling") {
        let success: Result<Int> = .success(42)
        let failure: Result<Int> = .failure("Invalid input")

        assertEqual(processResult(success), "Success: 42",
                   "Should include success value")
        assertEqual(processResult(failure), "Failed: Invalid input",
                   "Should include error message")
    }

    runTests()
}
