@testable import TrailBlazer
import XCTest

#if os(Linux)
import Glibc
#else
import Darwin
#endif

class StatTests: XCTestCase {

    func testInit() {
        let stat1 = StatInfo()
        XCTAssertNil(stat1.path)
        XCTAssertTrue(stat1.options.isEmpty)
        XCTAssertNil(stat1.fileDescriptor)

        let stat2 = StatInfo("/tmp")
        XCTAssertNotNil(stat2.path)
        XCTAssertTrue(stat2.options.isEmpty)
        XCTAssertNil(stat2.fileDescriptor)

        let fd = open("/tmp", O_DIRECTORY)
        guard fd > 0 else { return }
        let stat3 = StatInfo(fd)
        XCTAssertNil(stat3.path)
        XCTAssertTrue(stat3.options.isEmpty)
        XCTAssertNotNil(stat3.fileDescriptor)
    }

    func testType() {
        var stat1 = StatInfo("/tmp")
        XCTAssertNoThrow(try stat1.getInfo())
        XCTAssertEqual(stat1.type, .directory)
    }

    static var allTests = [
        ("testInit", testInit),
        ("testType", testType),
    ]
}
