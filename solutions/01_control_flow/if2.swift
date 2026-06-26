// if2.swift
//
// Multiple conditions can be combined using logical operators.
// && means AND - both conditions must be true
// || means OR - at least one condition must be true
//
// Fix the conditions to make the tests pass.

func checkTicketPrice(_ age: Int, _ isStudent: Bool) -> Double {
    let fullPrice = 20.0

    // Children (under 12) get 50% off
    if age < 12 {
        return fullPrice * 0.5
    }

    // Students OR seniors (65+) get 30% off
    if isStudent || age >= 65 {
        return fullPrice * 0.7
    }

    return fullPrice
}

func main() {
    print("ticket: child \(checkTicketPrice(5, false)), student \(checkTicketPrice(20, true)), adult \(checkTicketPrice(30, false))")

    test("Children get 50% discount") {
        assertEqual(checkTicketPrice(5, false), 10.0, "5-year-old should pay $10")
        assertEqual(checkTicketPrice(11, false), 10.0, "11-year-old should pay $10")
        assertEqual(checkTicketPrice(11, true), 10.0, "11-year-old student still pays child price")
    }

    test("Students get 30% discount") {
        assertEqual(checkTicketPrice(20, true), 14.0, "20-year-old student should pay $14")
        assertEqual(checkTicketPrice(25, true), 14.0, "25-year-old student should pay $14")
    }

    test("Seniors get 30% discount") {
        assertEqual(checkTicketPrice(65, false), 14.0, "65-year-old should pay $14")
        assertEqual(checkTicketPrice(80, false), 14.0, "80-year-old should pay $14")
    }

    test("Regular adults pay full price") {
        assertEqual(checkTicketPrice(30, false), 20.0, "30-year-old should pay full price")
        assertEqual(checkTicketPrice(45, false), 20.0, "45-year-old should pay full price")
    }

    runTests()
}
