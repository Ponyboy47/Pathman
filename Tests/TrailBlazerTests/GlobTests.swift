import XCTest
@testable import TrailBlazer

class GlobTests: XCTestCase {
    func testGlob() {
        do {
            let glob = try TrailBlazer.glob(pattern: "/tmp/*")
            XCTAssertFalse(glob.matches.isEmpty)
        } catch {
            XCTFail("Glob threw an error: \(error)")
        }
    }

    func testGlobDirectory() {
        guard let tmp = DirectoryPath("/tmp") else {
            return XCTFail("Failed to get the home directory")
        }

        do {
            let glob = try tmp.glob(pattern: "*")
            XCTAssertFalse(glob.matches.isEmpty)
        } catch {
            XCTFail("Glob threw an error: \(error)")
        }
    }

    static var allTests = [
        ("testGlob", testGlob),
        ("testGlobDirectory", testGlobDirectory),
    ]
}

