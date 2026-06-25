// init2.swift
//
// A failable initializer, written `init?`, can return nil when the inputs are
// not valid. This is common when parsing untrusted input into a typed value.
//
// Fix the initializer so it fails for invalid port numbers.

struct Port {
    let number: Int

    // TODO: Make this a failable initializer (init?). It should return nil when
    // `text` is not a whole number, or is outside the range 1...65535.
    init(_ text: String) {
        self.number = Int(text)
    }
}

func test() {
    assertEqual(Port("8080")?.number, 8080, "a valid port parses")
    assertNil(Port("abc"), "a non-number is nil")
    assertNil(Port("70000"), "out of range is nil")
    assertNil(Port("0"), "0 is not a valid port")
}

func main() {
    test()
    runTests()
}
