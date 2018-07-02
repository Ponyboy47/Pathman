import XCTest
import Foundation
@testable import TrailBlazer

class CreateDeleteTests: XCTestCase {

    func testCreateFile() {
        guard let file = FilePath("/tmp/abcdefg") else {
            XCTFail("Path /tmp/abcdefg exists and is not a file")
            return
        }

        do {
            let open = try file.create(mode: .ownerGroupOthers(.read, .write))
            XCTAssertTrue(file.exists)
            XCTAssertTrue(file.isFile)
            try open.write("Hello World")
        } catch {
            XCTFail("Failed to create/write to file with error \(error)")
        }
    }

    func testDeleteFile() {
        guard let file = FilePath("/tmp/abcdefg") else {
            XCTFail("Path /tmp/abcdefg exists and is not a file")
            return
        }

        XCTAssertNoThrow(try file.delete())
    }

    func testCreateDirectory() {
        guard let dir = DirectoryPath("/tmp/hijklmnop") else {
            XCTFail("Path /tmp/hijklmnop exists and is not a directory")
            return
        }

        XCTAssertNoThrow(try dir.create(mode: .ownerGroupOthers(.read, .write)))
        XCTAssertTrue(dir.exists)
        XCTAssertTrue(dir.isDirectory)
    }

    func testDeleteDirectory() {
        guard let dir = DirectoryPath("/tmp/hijklmnop") else {
            XCTFail("Path /tmp/hijklmnop exists and is not a directory")
            return
        }

        XCTAssertNoThrow(try dir.delete())
    }

    func testDeleteNonEmptyDirectory() {
    }

    static var allTests = [
        ("testCreateFile", testCreateFile),
        ("testDeleteFile", testDeleteFile),
        ("testCreateDirectory", testCreateDirectory),
        ("testDeleteDirectory", testDeleteDirectory),
    ]
}
