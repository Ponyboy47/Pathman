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

    func testCreation() {
        #if os(macOS)
        let _ = stat.creation
        #endif
    }

    func testDelegate() {
        let dir = DirectoryPath("/tmp")!

        let _ = dir.id
        let _ = dir.inode
        let _ = dir.permissions
        let _ = dir.owner
        let _ = dir.group
        let _ = dir.size
        let _ = dir.device
        let _ = dir.blockSize
        let _ = dir.blocks
        let _ = dir.lastAccess
        let _ = dir.lastModified
        let _ = dir.lastAttributeChange

        #if os(macOS)
        let _ = dir.creation
        #endif
    }

    func testCustomStringConvertible() {
        XCTAssertEqual(stat.description, "StatInfo(path: Optional(\"/tmp\"), fileDescriptor: nil, options: StatOptions(rawValue: 0))")
    }

    func testStatDelegate() {
        struct Foo: UpdatableStatDelegate {
            var _info: StatInfo

            init(_ path: String) {
                _info = StatInfo(path)
            }
        }

        let foo = Foo("/tmp")
        XCTAssertNotNil(foo.type)
        XCTAssertEqual(foo.type, .directory)

        XCTAssertNotEqual(foo.permissions, 0)
        XCTAssertNotEqual(foo.owner, 1234)
        XCTAssertNotEqual(foo.group, 1234)
    }
}
