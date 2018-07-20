import XCTest
@testable import TrailBlazer

class FilePermissionsTests: XCTestCase {
    func testRead() {
        let read: FilePermissions = .read
        XCTAssertEqual(read.rawValue, 0o4)
        XCTAssertEqual(FilePermissions("r--"), read)
    }

    func testWrite() {
        let write: FilePermissions = .write
        XCTAssertEqual(write.rawValue, 0o2)
        XCTAssertEqual(FilePermissions("-w-"), write)
    }

    func testExecute() {
        let execute: FilePermissions = .execute
        XCTAssertEqual(execute.rawValue, 0o1)
        XCTAssertEqual(FilePermissions("--x"), execute)
    }

    func testNone() {
        XCTAssertTrue(FilePermissions().hasNone)
        XCTAssertFalse(FilePermissions.read.hasNone)
        XCTAssertFalse(FilePermissions.write.hasNone)
        XCTAssertFalse(FilePermissions.execute.hasNone)
    }

    func testReadWrite() {
        let perms: FilePermissions = [.read, .write]
        XCTAssertEqual(perms.rawValue, 0o6)
        XCTAssertEqual(FilePermissions("rw-"), perms)
    }

    func testReadExecute() {
        let perms: FilePermissions = [.read, .execute]
        XCTAssertEqual(perms.rawValue, 0o5)
        XCTAssertEqual(FilePermissions("r-x"), perms)
    }

    func testWriteExecute() {
        let perms: FilePermissions = [.write, .execute]
        XCTAssertEqual(perms.rawValue, 0o3)
        XCTAssertEqual(FilePermissions("-wx"), perms)
    }

    func testReadWriteExecute() {
        let perms: FilePermissions = [.read, .write, .execute]
        XCTAssertEqual(perms.rawValue, 0o7)
        XCTAssertEqual(FilePermissions("rwx"), perms)
    }

    static var allTests = [
        ("testRead", testRead),
        ("testWrite", testWrite),
        ("testExecute", testExecute),
        ("testNone", testNone),
        ("testReadWrite", testReadWrite),
        ("testReadExecute", testReadExecute),
        ("testWriteExecute", testWriteExecute),
        ("testReadWriteExecute", testReadWriteExecute),
    ]
}

