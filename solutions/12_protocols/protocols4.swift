// protocols4.swift
//
// Protocols are commonly used for delegation patterns and can have
// class-only constraints for reference semantics.
//
// Fix the delegation pattern and protocol constraints to make the tests pass.

protocol DownloadDelegate: AnyObject {
    func downloadDidStart()
    func downloadDidFinish(data: String)
    func downloadDidFail(error: String)
}

class Downloader {
    weak var delegate: DownloadDelegate?

    func startDownload() {
        delegate?.downloadDidStart()

        // Simulate download
        let success = true

        if success {
            delegate?.downloadDidFinish(data: "Downloaded content")
        } else {
            delegate?.downloadDidFail(error: "Network error")
        }
    }
}

class ViewController {
    var statusText = "Ready"
    let downloader = Downloader()

    init() {
        downloader.delegate = self
    }
}

protocol Identifiable: AnyObject {
    var id: String { get set }
}

// A class can adopt the class-only Identifiable protocol. A struct cannot,
// which is exactly the point of constraining it to AnyObject.
class ProductClass: Identifiable {
    var id: String

    init(id: String) {
        self.id = id
    }
}

func main() {
    let viewController = ViewController()
    viewController.downloader.startDownload()
    print(viewController.statusText)

    test("Delegation pattern") {
        let viewController = ViewController()

        // Start download
        viewController.downloader.startDownload()

        // Check that delegate methods were called
        assertEqual(viewController.statusText, "Download complete: Downloaded content",
                   "Status should be updated by delegate")
    }

    test("Weak delegate reference") {
        var viewController: ViewController? = ViewController()
        let downloader = viewController!.downloader

        // Clear strong reference
        viewController = nil

        // Delegate should be nil (weak reference)
        assertNil(downloader.delegate, "Delegate should be released")
    }

    test("Class-only protocol") {
        // This test verifies that only classes can conform
        let product = ProductClass(id: "P123")
        product.id = "P456"
        assertEqual(product.id, "P456", "Can modify class property")
    }

    runTests()
}

// Implementations for delegate methods
extension ViewController: DownloadDelegate {
    func downloadDidStart() {
        statusText = "Downloading..."
    }

    func downloadDidFinish(data: String) {
        statusText = "Download complete: \(data)"
    }

    func downloadDidFail(error: String) {
        statusText = "Download failed: \(error)"
    }
}
