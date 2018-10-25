import XCTest
@testable import TrailBlazer

class TemporaryTests: XCTestCase {
    func testTemporaryFile() {
        do {
            let tmpFile = try FilePath.temporary(prefix: "Test-")
            XCTAssertTrue(tmpFile.path.lastComponent!.hasPrefix("Test-"))

            XCTAssertTrue(tmpFile.exists)
            XCTAssertNoThrow(try tmpFile.path.delete())
        } catch {
            XCTFail("Failed to create/open temporary file with error: \(type(of: error)).\(error)")
            return
        }
    }

    func testTemporaryDirectory() {
        do {
            let tmpDirectory = try DirectoryPath.temporary(prefix: "Test-")
            XCTAssertTrue(tmpDirectory.path.lastComponent!.hasPrefix("Test-"))

            XCTAssertTrue(tmpDirectory.exists)
            XCTAssertNoThrow(try tmpDirectory.path.delete())
        } catch {
            XCTFail("Failed to create/open temporary file with error: \(type(of: error)).\(error)")
            return
        }
    }

    func testTemporaryWithClosure() {
        do {
            let tmpFile = try FilePath.temporary(prefix: "com.trailblazer.test.", options: .deleteOnCompletion) { openFile in
                XCTAssertTrue(openFile.path.exists)
                XCTAssertNoThrow(try openFile.write("Hello world"))
                XCTAssertEqual(try! openFile.path.read(), "Hello world")
            }
            XCTAssertFalse(tmpFile.exists)

            let tmpDirectory = try DirectoryPath.temporary(prefix: "com.trailblazer.test.", options: .deleteOnCompletion) { openDirectory in
                XCTAssertTrue(openDirectory.path.exists)
                var path = FilePath(openDirectory.path + "test")!
                XCTAssertNoThrow(try path.create())
            }
            XCTAssertFalse(tmpDirectory.exists)
        } catch {
            XCTFail("Failed to create temporary file or directory")
        }
    }
}
