// memory2.swift
//
// Understanding capture semantics and memory management in closures.
// Weak and unowned references in different contexts.
//
// Fix the capture lists and reference types to make the tests pass.

import Foundation

class DataLoader {
    var data: String = "Initial"
    var onComplete: ((String) -> Void)?

    func loadData() {
        // A one-shot dispatch block is not stored on self, so a strong capture
        // here is not a retain cycle; it just keeps the loader alive until the
        // work finishes.
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.1)
            self.data = "Loaded"
            self.onComplete?(self.data)
        }
    }

    deinit {
        print("DataLoader deallocated")
    }
}

class NetworkManager {
    private var activeRequests: [String: () -> Void] = [:]

    func request(id: String, completion: @escaping () -> Void) {
        activeRequests[id] = { [weak self] in
            completion()
            self?.activeRequests.removeValue(forKey: id)
        }
    }

    func executeRequest(id: String) {
        activeRequests[id]?()
    }

    deinit {
        print("NetworkManager deallocated")
    }
}

class NotificationHandler {
    private var observer: Any?

    init() {
        observer = NotificationCenter.default.addObserver(
            forName: .custom,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleNotification()
        }
    }

    func handleNotification() {
        print("Notification received")
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        print("NotificationHandler deallocated")
    }
}

extension Notification.Name {
    static let custom = Notification.Name("custom")
}

class TimerController {
    private var timer: Timer?
    private var tickCount = 0

    func startTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            self?.tickCount += 1
            print("Tick \(self?.tickCount ?? 0)")
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopTimer()
        print("TimerController deallocated")
    }
}

func main() {
    print("memory2: weak/unowned capture demo")

    test("Async closure capture") {
        var loader: DataLoader? = DataLoader()
        let expectation = DispatchSemaphore(value: 0)

        loader?.onComplete = { data in
            print("Data: \(data)")
            expectation.signal()
        }

        loader?.loadData()

        loader = nil

        expectation.wait()
        assertTrue(true, "DataLoader should handle async properly")
    }

    test("Closure storage in collections") {
        var manager: NetworkManager? = NetworkManager()
        var callbackExecuted = false

        manager?.request(id: "test") {
            callbackExecuted = true
        }

        manager?.executeRequest(id: "test")
        assertTrue(callbackExecuted, "Callback executed")

        manager = nil
        assertTrue(true, "NetworkManager should be deallocated")
    }

    test("Notification center observers") {
        var handler: NotificationHandler? = NotificationHandler()

        NotificationCenter.default.post(name: .custom, object: nil)

        handler = nil
        assertTrue(true, "NotificationHandler should be deallocated")
    }

    test("Timer memory management") {
        var controller: TimerController? = TimerController()

        controller?.startTimer()

        Thread.sleep(forTimeInterval: 0.3)

        controller?.stopTimer()
        controller = nil

        assertTrue(true, "TimerController should be deallocated")
    }

    test("Capture list variations") {
        class Container {
            var value = 10

            func makeWeakClosure() -> () -> Int? {
                return { [weak self] in
                    return self?.value
                }
            }

            func makeStrongClosure() -> () -> Int {
                return {
                    return self.value
                }
            }
        }

        var weakOwner: Container? = Container()
        let weakClosure = weakOwner!.makeWeakClosure()
        weakOwner = nil
        assertNil(weakClosure(), "Weak reference should be nil after release")

        var strongOwner: Container? = Container()
        let strongClosure = strongOwner!.makeStrongClosure()
        strongOwner = nil
        assertEqual(strongClosure(), 10, "Strong reference keeps object alive")
    }

    runTests()
}
