@testable import PathMan
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
        XCTAssertNil(stat1._descriptor)

        let stat2 = StatInfo("/tmp")
        XCTAssertNotNil(stat2._path)
        XCTAssertTrue(stat2.options.isEmpty)
        XCTAssertNil(stat2._descriptor)

        let fd = open("/tmp", O_DIRECTORY)
        guard fd > 0 else { return }
        let stat3 = StatInfo(fd)
        XCTAssertNil(stat3._path)
        XCTAssertTrue(stat3.options.isEmpty)
        XCTAssertNotNil(stat3._descriptor)
    }

    func testType() {
        XCTAssertEqual(stat.type, .directory)
    }

    func testID() {
        _ = stat.id
    }

    func testInode() {
        _ = stat.inode
    }

    func testPermissions() {
        _ = stat.permissions
    }

    func testOwner() {
        _ = stat.owner
    }

    func testGroup() {
        _ = stat.group
    }

    func testSize() {
        _ = stat.size
    }

    func testDevice() {
        _ = stat.device
    }

    func testBlockSize() {
        _ = stat.blockSize
    }

    func testBlocks() {
        _ = stat.blocks
    }

    func testAccess() {
        _ = stat.lastAccess
    }

    func testModified() {
        _ = stat.lastModified
    }

    func testAttributeChange() {
        _ = stat.lastAttributeChange
    }

    func testCreation() {
        #if os(macOS)
        _ = stat.creation
        #endif
    }

    func testDelegate() {
        let dir = DirectoryPath("/tmp")!

        _ = dir.id
        _ = dir.inode
        _ = dir.permissions
        _ = dir.owner
        _ = dir.group
        _ = dir.size
        _ = dir.device
        _ = dir.blockSize
        _ = dir.blocks
        _ = dir.lastAccess
        _ = dir.lastModified
        _ = dir.lastAttributeChange

        #if os(macOS)
        _ = dir.creation
        #endif
    }

    func testCustomStringConvertible() {
        XCTAssertEqual(stat.description, "StatInfo(path: Optional(\"/tmp\"), fileDescriptor: nil, options: StatOptions(rawValue: 0))")
    }

    func testStatDelegate() {
        struct Foo: UpdatableStatable {
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
