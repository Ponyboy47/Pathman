@testable import PathMan
import XCTest

class FilePermissionsTests: XCTestCase {
    func testRead() {
        let read: FilePermissions = .read
        XCTAssertEqual(read.rawValue, 0o4)
        XCTAssertEqual(FilePermissions("r--"), read)
        XCTAssertEqual("r--", read)
    }

    func testWrite() {
        let write: FilePermissions = .write
        XCTAssertEqual(write.rawValue, 0o2)
        XCTAssertEqual(FilePermissions("-w-"), write)
        XCTAssertEqual("-w-", write)
    }

    func testExecute() {
        let execute: FilePermissions = .execute
        XCTAssertEqual(execute.rawValue, 0o1)
        XCTAssertEqual(FilePermissions("--x"), execute)
        XCTAssertEqual("--x", execute)
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
        XCTAssertEqual("rw-", perms)
    }

    func testReadExecute() {
        let perms: FilePermissions = [.read, .execute]
        XCTAssertEqual(perms.rawValue, 0o5)
        XCTAssertEqual(FilePermissions("r-x"), perms)
        XCTAssertEqual("r-x", perms)
    }

    func testWriteExecute() {
        let perms: FilePermissions = [.write, .execute]
        XCTAssertEqual(perms.rawValue, 0o3)
        XCTAssertEqual(FilePermissions("-wx"), perms)
        XCTAssertEqual("-wx", perms)
    }

    func testReadWriteExecute() {
        let perms: FilePermissions = [.read, .write, .execute]
        XCTAssertEqual(perms.rawValue, 0o7)
        XCTAssertEqual(FilePermissions("rwx"), perms)
        XCTAssertEqual("rwx", perms)
    }

    func testOrOperator() {
        let all: FilePermissions = .all
        let read: FilePermissions = .read
        let write: FilePermissions = .write
        let execute: FilePermissions = .execute
        var empty: FilePermissions = .none

        XCTAssertEqual(read | write | execute, all)
        XCTAssertEqual(read | write.rawValue | execute.rawValue, all)

        XCTAssertNotEqual(empty, all)
        empty |= read
        XCTAssertEqual(empty, read)
        empty |= (write | execute).rawValue
        XCTAssertEqual(empty, all)
    }

    func testAndOperator() {
        var all: FilePermissions = .all
        let read: FilePermissions = .read
        let write: FilePermissions = .write
        let execute: FilePermissions = .execute
        let empty: FilePermissions = .none

        XCTAssertEqual(all & read, read)
        XCTAssertEqual(all & write.rawValue, write)

        XCTAssertNotEqual(empty, all)
        all &= execute
        XCTAssertEqual(all, execute)
        all &= (write | read).rawValue
        XCTAssertEqual(empty, all)
    }

    func testNotOperator() {
        let all: FilePermissions = .all
        let read: FilePermissions = .read
        let write: FilePermissions = .write
        let execute: FilePermissions = .execute
        let empty: FilePermissions = .none

        XCTAssertNotEqual(all, empty)
        XCTAssertEqual(~all, empty)
        XCTAssertEqual(all, ~empty)
        XCTAssertNotEqual(~all, ~empty)

        XCTAssertEqual(~read, write | execute)
        XCTAssertEqual(~write, read | execute)
        XCTAssertEqual(~execute, read | write)

        XCTAssertEqual(~(read | write), execute)
        XCTAssertEqual(~(read | execute), write)
        XCTAssertEqual(~(write | execute), read)
    }
}
