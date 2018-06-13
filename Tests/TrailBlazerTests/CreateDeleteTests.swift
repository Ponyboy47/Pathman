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
            let open = try file.create(mode: .ownerGroupOthers(.read, .write))
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
        guard let dir = DirectoryPath("/tmp/hijklmnop") else {
            XCTFail("Path /tmp/hijklmnop exists and is not a directory")
            return
        }

        XCTAssertNoThrow(try dir.create(mode: .ownerGroupOthers(.read, .write)))
    }

    func deleteDirectory() {
        guard let dir = DirectoryPath("/tmp/hijklmnop") else {
            XCTFail("Path /tmp/hijklmnop exists and is not a directory")
            return
        }

        XCTAssertNoThrow(try dir.delete())
    }

    func deleteNonEmptyDirectory() {
    }

    static var allTests = [
        ("createFile", createFile),
        ("deleteFile", deleteFile),
        ("createDirectory", createDirectory),
        ("deleteDirectory", deleteDirectory),
    ]
}
