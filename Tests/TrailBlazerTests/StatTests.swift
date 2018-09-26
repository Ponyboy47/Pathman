@testable import TrailBlazer
import XCTest

#if os(Linux)
import Glibc
#else
import Darwin
#endif

class StatTests: XCTestCase {
    var _stat = StatInfo("/tmp")
    var stat: StatInfo {
        try? _stat.getInfo()
        return _stat
    }

    func testInit() {
        let stat1 = StatInfo()
        XCTAssertNil(stat1._path)
        XCTAssertTrue(stat1.options.isEmpty)
        XCTAssertNil(stat1.fileDescriptor)

        let stat2 = StatInfo("/tmp")
        XCTAssertNotNil(stat2._path)
        XCTAssertTrue(stat2.options.isEmpty)
        XCTAssertNil(stat2.fileDescriptor)

        let fd = open("/tmp", O_DIRECTORY)
        guard fd > 0 else { return }
        let stat3 = StatInfo(fd)
        XCTAssertNil(stat3._path)
        XCTAssertTrue(stat3.options.isEmpty)
        XCTAssertNotNil(stat3.fileDescriptor)
    }

    func testType() {
        XCTAssertEqual(stat.type, .directory)
    }

    func testID() {
        let _ = stat.id
    }

    func testInode() {
        let _ = stat.inode
    }

    func testPermissions() {
        let _ = stat.permissions
    }

    func testOwner() {
        let _ = stat.owner
    }

    func testGroup() {
        let _ = stat.group
    }

    func testSize() {
        let _ = stat.size
    }

    func testDevice() {
        let _ = stat.device
    }

    func testBlockSize() {
        let _ = stat.blockSize
    }

    func testBlocks() {
        let _ = stat.blocks
    }

    func testAccess() {
        let _ = stat.lastAccess
    }

    func testModified() {
        let _ = stat.lastModified
    }

    func testAttributeChange() {
        let _ = stat.lastAttributeChange
    }
}
