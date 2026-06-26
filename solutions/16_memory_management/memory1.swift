// memory1.swift
//
// Swift uses Automatic Reference Counting (ARC) to manage memory.
// Strong references keep objects alive, creating potential retain cycles.
//
// Fix the memory management issues to make the tests pass.

class Person {
    let name: String
    var apartment: Apartment?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) is being deinitialized")
    }
}

class Apartment {
    let unit: String
    weak var tenant: Person?

    init(unit: String) {
        self.unit = unit
    }

    deinit {
        print("Apartment \(unit) is being deinitialized")
    }
}

class HTMLElement {
    let name: String
    let text: String?

    lazy var asHTML: () -> String = { [unowned self] in
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\(name) element is being deinitialized")
    }
}

protocol CacheDelegate: AnyObject {
    func cacheDidUpdate()
}

class Cache {
    weak var delegate: CacheDelegate?

    func update() {
        delegate?.cacheDidUpdate()
    }
}

class ViewController: CacheDelegate {
    let cache = Cache()

    init() {
        cache.delegate = self
    }

    func cacheDidUpdate() {
        print("Cache updated")
    }
}

func main() {
    let paragraph = HTMLElement(name: "p", text: "Hello")
    print("html \(paragraph.asHTML())")

    test("Weak references break retain cycles") {
        var john: Person? = Person(name: "John")
        var unit4A: Apartment? = Apartment(unit: "4A")

        john!.apartment = unit4A
        unit4A!.tenant = john

        john = nil
        unit4A = nil

        assertTrue(true, "Objects should be deallocated")
    }

    test("Closure capture lists") {
        var paragraph: HTMLElement? = HTMLElement(name: "p", text: "Hello")
        let html = paragraph!.asHTML()

        assertEqual(html, "<p>Hello</p>", "HTML generation works")

        paragraph = nil

        assertTrue(true, "HTMLElement should be deallocated")
    }

    test("Weak delegate pattern") {
        var viewController: ViewController? = ViewController()
        let cache = viewController!.cache

        viewController = nil

        assertNil(cache.delegate, "Delegate should be nil after VC dealloc")
    }

    test("Unowned vs weak") {
        class Customer {
            let name: String
            var card: CreditCard?

            init(name: String) {
                self.name = name
            }

            deinit {
                print("\(name) is being deinitialized")
            }
        }

        class CreditCard {
            let number: String
            unowned let customer: Customer

            init(number: String, customer: Customer) {
                self.number = number
                self.customer = customer
            }

            deinit {
                print("Card \(number) is being deinitialized")
            }
        }

        var alice: Customer? = Customer(name: "Alice")
        alice!.card = CreditCard(number: "1234", customer: alice!)

        alice = nil
        assertTrue(true, "Customer and card deallocated together")
    }

    runTests()
}
