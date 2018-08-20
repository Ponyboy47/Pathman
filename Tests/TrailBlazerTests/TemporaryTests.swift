import XCTest
@testable import TrailBlazer

class TemporaryTests: XCTestCase {
    func testTemporaryFile() {
        do {
            let tmpFile = try FilePath.temporary(prefix: "Test-")
            XCTAssertTrue(tmpFile._path.lastComponent!.hasPrefix("Test-"))

            XCTAssertNoThrow(try tmpFile.delete())
        } catch {
            XCTFail("Failed to create/open temporary file with error: \(type(of: error)).\(error)")
            return
        }
    }

    func testTemporaryDirectory() {
        do {
            let tmpDirectory = try DirectoryPath.temporary(prefix: "Test-")
            XCTAssertTrue(tmpDirectory._path.lastComponent!.hasPrefix("Test-"))

            XCTAssertNoThrow(try tmpDirectory.delete())
        } catch {
            XCTFail("Failed to create/open temporary file with error: \(type(of: error)).\(error)")
            return
        }
    }

    static var allTests = [
        ("testTemporaryFile", testTemporaryFile),
        ("testTemporaryDirectory", testTemporaryDirectory),
    ]
}
