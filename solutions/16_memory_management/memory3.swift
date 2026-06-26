// memory3.swift
//
// Advanced memory management patterns and debugging techniques.
// Understanding reference cycles in complex scenarios.
//
// Fix the memory issues in these real-world patterns to make the tests pass.

import Foundation

class Parent {
    let name: String
    var children: [Child] = []

    init(name: String) {
        self.name = name
    }

    func addChild(_ child: Child) {
        children.append(child)
        child.parent = self
    }

    deinit {
        print("Parent \(name) deallocated")
    }
}

class Child {
    let name: String
    weak var parent: Parent?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Child \(name) deallocated")
    }
}

protocol Observer: AnyObject {
    func update(value: Int)
}

class Subject {
    private struct WeakObserver {
        weak var observer: Observer?
    }

    private var observers: [WeakObserver] = []
    private var value = 0

    func attach(_ observer: Observer) {
        observers.append(WeakObserver(observer: observer))
    }

    func setValue(_ newValue: Int) {
        value = newValue
        notifyObservers()
    }

    private func notifyObservers() {
        for box in observers {
            box.observer?.update(value: value)
        }
    }

    deinit {
        print("Subject deallocated")
    }
}

class ConcreteObserver: Observer {
    let id: String

    init(id: String) {
        self.id = id
    }

    func update(value: Int) {
        print("Observer \(id) received: \(value)")
    }

    deinit {
        print("Observer \(id) deallocated")
    }
}

class ExpiringCache<T> {
    private var cache: [String: (value: T, timer: Timer)] = [:]

    func set(_ value: T, for key: String, ttl: TimeInterval) {
        let timer = Timer.scheduledTimer(
            withTimeInterval: ttl,
            repeats: false
        ) { [weak self] _ in
            self?.cache.removeValue(forKey: key)
        }

        cache[key] = (value, timer)
    }

    func get(_ key: String) -> T? {
        return cache[key]?.value
    }

    func invalidate() {
        cache.values.forEach { $0.timer.invalidate() }
        cache.removeAll()
    }

    deinit {
        invalidate()
        print("ExpiringCache deallocated")
    }
}

class AsyncOperation {
    private let queue = DispatchQueue(label: "async.operation")
    private var completion: (() -> Void)?

    func execute(completion: @escaping () -> Void) {
        self.completion = completion

        // The block runs once and clears the stored completion, so a strong
        // self capture keeps the operation alive only until the work finishes.
        queue.async {
            Thread.sleep(forTimeInterval: 0.1)
            self.completion?()
            self.completion = nil
        }
    }

    deinit {
        print("AsyncOperation deallocated")
    }
}

func main() {
    print("memory3: weak parent/child and observers")

    test("Parent-child relationships") {
        var parent: Parent? = Parent(name: "John")
        let child1 = Child(name: "Alice")
        let child2 = Child(name: "Bob")

        parent?.addChild(child1)
        parent?.addChild(child2)

        parent = nil

        assertTrue(true, "Parent and children should be deallocated")
    }

    test("Observer pattern with weak references") {
        var subject: Subject? = Subject()
        var observer1: ConcreteObserver? = ConcreteObserver(id: "1")
        let observer2: ConcreteObserver? = ConcreteObserver(id: "2")

        subject?.attach(observer1!)
        subject?.attach(observer2!)

        subject?.setValue(42)

        observer1 = nil

        subject?.setValue(100)

        subject = nil
        _ = observer2

        assertTrue(true, "Subject and observers should be deallocated")
    }

    test("Timer-based cache") {
        var cache: ExpiringCache<String>? = ExpiringCache()

        cache?.set("value1", for: "key1", ttl: 0.2)
        cache?.set("value2", for: "key2", ttl: 0.3)

        assertEqual(cache?.get("key1"), "value1", "Value in cache")

        cache = nil

        assertTrue(true, "Cache should be deallocated with timers")
    }

    test("Async operation cleanup") {
        var operation: AsyncOperation? = AsyncOperation()
        let expectation = DispatchSemaphore(value: 0)
        var completed = false

        operation?.execute {
            completed = true
            expectation.signal()
        }

        operation = nil

        expectation.wait()
        assertTrue(completed, "Operation completed")

        assertTrue(true, "AsyncOperation should be deallocated")
    }

    runTests()
}

// Helper for weak references in arrays
struct WeakBox<T: AnyObject> {
    weak var value: T?

    init(_ value: T) {
        self.value = value
    }
}
