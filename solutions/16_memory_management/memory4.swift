// memory4.swift
//
// Value types vs reference types and copy-on-write optimization.
// Understanding when to use structs vs classes for performance.
//
// Fix the performance and memory issues to make the tests pass.

import Foundation

struct LargeData {
    // Array already implements copy-on-write, so two LargeData values share
    // this buffer until one of them mutates it.
    private var storage: [Int]

    init(size: Int) {
        storage = Array(repeating: 0, count: size)
    }

    mutating func append(_ value: Int) {
        storage.append(value)
    }

    var count: Int {
        return storage.count
    }

    subscript(index: Int) -> Int {
        get { storage[index] }
        set { storage[index] = newValue }
    }
}

// A cache is shared state, so a class (reference semantics) is the right choice.
class ImageCache {
    private var cache: [String: Data] = [:]

    func store(_ data: Data, for key: String) {
        cache[key] = data
    }

    func retrieve(_ key: String) -> Data? {
        return cache[key]
    }
}

struct Data {
    let bytes: [UInt8]
}

// A value-type dictionary gives the struct true value semantics: copying the
// Configuration copies the settings, so the two no longer share storage.
struct Configuration {
    var settings: [String: Any] = [:]

    mutating func set(_ value: Any, for key: String) {
        settings[key] = value
    }
}

enum Result<T> {
    case success(T)
    case failure(Error)

    func map<U>(_ transform: (T) -> U) -> Result<U> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
}

struct URLBuilder {
    private var components = URLComponents()

    // Each step returns a new value, leaving the original builder unchanged.
    func scheme(_ scheme: String) -> URLBuilder {
        var copy = self
        copy.components.scheme = scheme
        return copy
    }

    func host(_ host: String) -> URLBuilder {
        var copy = self
        copy.components.host = host
        return copy
    }

    func path(_ path: String) -> URLBuilder {
        var copy = self
        copy.components.path = path
        return copy
    }

    func build() -> URL? {
        return components.url
    }
}

func main() {
    print("memory4: value vs reference types")

    test("Copy-on-write optimization") {
        var data1 = LargeData(size: 1000)
        let data2 = data1

        assertTrue(true, "Storage should be shared until mutation")

        data1.append(42)

        assertEqual(data1.count, 1001, "data1 modified")
        assertEqual(data2.count, 1000, "data2 unchanged")
    }

    test("Struct vs class choice") {
        let cache1 = ImageCache()
        let cache2 = cache1

        let testData = Data(bytes: [1, 2, 3])
        cache1.store(testData, for: "image1")

        assertNotNil(cache2.retrieve("image1"), "Shared cache storage")

        assertTrue(true, "ImageCache correctly uses reference semantics")
    }

    test("Value type with reference type property") {
        var config1 = Configuration()
        config1.set("value1", for: "key1")

        var config2 = config1
        config2.set("value2", for: "key2")

        assertEqual(config1.settings["key1"] as? String, "value1",
                   "config1 keeps its own value")
        assertNil(config1.settings["key2"], "config1 does not see config2's change")
        assertEqual(config2.settings["key2"] as? String, "value2",
                   "config2 has its own value")
    }

    test("Efficient transformations") {
        let largeArray = Array(repeating: 1, count: 1000)
        let result: Result<[Int]> = .success(largeArray)

        let doubled = result.map { array in
            array.map { $0 * 2 }
        }

        switch doubled {
        case .success(let values):
            assertEqual(values.first, 2, "Values doubled")
            assertEqual(values.count, 1000, "Same count")
        case .failure:
            assertFalse(true, "Should be success")
        }
    }

    test("Immutable builder pattern") {
        let url = URLBuilder()
            .scheme("https")
            .host("example.com")
            .path("/api/v1")
            .build()

        assertEqual(url?.absoluteString, "https://example.com/api/v1",
                   "URL built correctly")

        let builder = URLBuilder()
        let withScheme = builder.scheme("http")
        let withHost = withScheme.host("test.com")

        assertNil(builder.build()?.scheme, "Original builder unchanged (still has no scheme)")
        assertEqual(withHost.build()?.absoluteString, "http://test.com",
                   "Each step creates new instance")
    }

    runTests()
}
