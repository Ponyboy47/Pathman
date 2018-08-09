import XCTest
@testable import TrailBlazer

class TemporaryTests: XCTestCase {
    func testTemporaryFile() {
        let tmpFile: OpenFile
        do {
            tmpFile = try FilePath.temporary(prefix: "Test-")
            XCTAssertTrue(tmpFile._path.lastComponent!.hasPrefix("Test-"))
        } catch {
            XCTFail("Failed to create/open temporary file with error: \(type(of: error)).\(error)")
            return
        }
        try? tmpFile.delete()
    }

    func testTemporaryDirectory() {
        let tmpDirectory: OpenDirectory
        do {
            tmpDirectory = try DirectoryPath.temporary(prefix: "Test-")
            XCTAssertTrue(tmpDirectory._path.lastComponent!.hasPrefix("Test-"))
        } catch {
            XCTFail("Failed to create/open temporary file with error: \(type(of: error)).\(error)")
            return
        }
        try? tmpDirectory.delete()
    }

    static var allTests = [
        ("testTemporaryFile", testTemporaryFile),
        ("testTemporaryDirectory", testTemporaryDirectory),
    ]
}


