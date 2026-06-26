// concurrency3.swift
//
// Actors provide safe concurrent access to mutable state.
// MainActor ensures UI updates happen on the main thread.
//
// Fix the actor implementations to make the tests pass.

import Foundation

actor BankAccount {
    private var balance: Double = 0

    func deposit(_ amount: Double) {
        balance += amount
    }

    func withdraw(_ amount: Double) -> Bool {
        if balance >= amount {
            balance -= amount
            return true
        }
        return false
    }

    func getBalance() -> Double {
        return balance
    }
}

actor Counter {
    private var value = 0

    func getValue() -> Int {
        return value
    }

    func increment() {
        value += 1
    }

    func getCurrentValue() -> Int {
        return value
    }
}

actor ViewModel {
    var uiState = "Initial"

    func updateUI(_ newState: String) {
        uiState = newState
    }

    func loadData() async {
        let data = await fetchHeavyData()
        updateUI(data)
    }
}

func fetchHeavyData() async -> String {
    try? await Task.sleep(nanoseconds: 100_000_000)
    return "Loaded data"
}

actor DataCache {
    private var cache: [String: String] = [:]

    func set(_ value: String, for key: String) {
        cache[key] = value
    }

    func get(_ key: String) -> String? {
        return cache[key]
    }

    var count: Int {
        return cache.count
    }
}

actor NetworkManager {
    static let shared = NetworkManager()

    private var activeRequests = 0

    func startRequest() {
        activeRequests += 1
    }

    func endRequest() {
        activeRequests -= 1
    }

    func getActiveCount() -> Int {
        return activeRequests
    }
}

func main() {
    print("concurrency3: actors")

    test("Actor prevents data races") {
        let expectation = DispatchSemaphore(value: 0)
        let account = BankAccount()

        Task {
            await withTaskGroup(of: Void.self) { group in
                for _ in 0..<1000 {
                    group.addTask {
                        await account.deposit(1)
                    }
                }
            }

            let balance = await account.getBalance()
            assertEqual(balance, 1000.0, "All deposits should be atomic")
            expectation.signal()
        }

        expectation.wait()
    }

    test("Actor method isolation") {
        let expectation = DispatchSemaphore(value: 0)
        let counter = Counter()

        Task {
            await counter.increment()
            await counter.increment()

            let value = await counter.getCurrentValue()
            assertEqual(value, 2, "Counter should be 2")

            // Nonisolated member can be read synchronously.
            let id = counter.id
            assertNotNil(id, "Should access nonisolated property")

            expectation.signal()
        }

        expectation.wait()
    }

    test("Async view model loading") {
        let expectation = DispatchSemaphore(value: 0)
        let viewModel = ViewModel()

        Task {
            await viewModel.loadData()

            let state = await viewModel.uiState
            assertEqual(state, "Loaded data", "State updated after loading")

            expectation.signal()
        }

        expectation.wait()
    }

    test("Actor with nonisolated members") {
        let expectation = DispatchSemaphore(value: 0)
        let cache = DataCache()

        Task {
            await cache.set("value1", for: "key1")
            await cache.set("value2", for: "key2")

            let value = await cache.get("key1")
            assertEqual(value, "value1", "Cache should work")

            let count = await cache.count
            assertEqual(count, 2, "Should have 2 items")

            expectation.signal()
        }

        expectation.wait()
    }

    test("Global actor usage") {
        let expectation = DispatchSemaphore(value: 0)

        Task {
            await NetworkManager.shared.startRequest()
            await NetworkManager.shared.startRequest()

            let count = await NetworkManager.shared.getActiveCount()
            assertEqual(count, 2, "Should have 2 active requests")

            await NetworkManager.shared.endRequest()
            let newCount = await NetworkManager.shared.getActiveCount()
            assertEqual(newCount, 1, "Should have 1 active request")

            expectation.signal()
        }

        expectation.wait()
    }

    runTests()
}

// Extensions for nonisolated members
extension Counter {
    nonisolated var id: String {
        return "Counter"
    }
}

extension DataCache {
    nonisolated var isEmpty: Bool {
        // A nonisolated member cannot read the actor's mutable state, so this
        // is a constant. (Real code would store an immutable flag instead.)
        return false
    }
}
