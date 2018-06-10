import XCTest
import Foundation
@testable import TrailBlazer

class CreateDeleteTests: XCTestCase {

    func createFile() {
        guard let file = FilePath("/tmp/abcdefg") else {
            XCTFail("Path /tmp/abcdefg exists and is not a file")
            return
        }

        do {
            guard let open = try (file.create(mode: .ownerGroupOthers(.read, .write)) as? FileWriter) else {
                XCTFail("Failed to cast open file as FileWriter")
                return
            }
            try open.write("Hello World")
        } catch {
            XCTFail("Failed to create/write to file with error \(error)")
        }
    }

    func deleteFile() {
        guard let file = FilePath("/tmp/abcdefg") else {
            XCTFail("Path /tmp/abcdefg exists and is not a file")
            return
        }

        XCTAssertNoThrow(try file.delete())
    }

    func createDirectory() {
    }

    func deleteDirectory() {
    }

    func deleteNonEmptyDirectory() {
    }

    static var allTests = [
        ("createFile", createFile),
        ("deleteFile", deleteFile),
    ]
}
