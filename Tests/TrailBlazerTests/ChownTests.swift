import XCTest
import Foundation
@testable import TrailBlazer

#if os(Linux)
import Glibc
#else
import Darwin
#endif

class ChownTests: XCTestCase {
    lazy var testUID: uid_t = {
        let eUID = geteuid()
        return eUID == 0 ? eUID + 1 : eUID - 1
    }()
    lazy var testGID: gid_t = {
        let eGID = getegid()
        return eGID == 0 ? eGID + 1 : eGID - 1
    }()

    func testSetOwner() {
        // Can't set the owner unless you're a privileged user, like root (uid == 0)
        guard geteuid() == 0 else { return }

        var file: FilePath
        do {
            file = try FilePath.temporary(prefix: "com.trailblazer.test.").path
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        file.owner = testUID
        XCTAssertEqual(testUID, file.owner)
        XCTAssertNotEqual(geteuid(), file.owner)
        XCTAssertEqual(getegid(), file.group)
        XCTAssertNotNil(file.ownerName)

        try? file.delete()
    }

    func testSetGroup() {
        // Can't set the group unless you're a privileged user, like root (uid
        // == 0) or if youre changing the group to one of the groups you are a
        // part of (too much work to get the list of groups the process's user
        // is a part of)
        guard geteuid() == 0 else { return }

        var file: FilePath
        do {
            file = try FilePath.temporary(prefix: "com.trailblazer.test.").path
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        file.group = testGID
        XCTAssertEqual(testGID, file.group)
        XCTAssertNotEqual(getegid(), file.group)
        XCTAssertEqual(geteuid(), file.owner)
        XCTAssertNotNil(file.groupName)

        try? file.delete()
    }

    func testSetBoth() {
        // Can't set the owner unless you're a privileged user, like root (uid == 0)
        // Can't set the group unless you're a privileged user, like root (uid
        // == 0) or if youre changing the group to one of the groups you are a
        // part of (too much work to get the list of groups the process's user
        // is a part of)
        guard geteuid() == 0 else { return }

        var file: FilePath
        do {
            file = try FilePath.temporary(prefix: "com.trailblazer.test.").path
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        XCTAssertNoThrow(try file.change(owner: testUID, group: testGID))
        XCTAssertEqual(testUID, file.owner)
        XCTAssertNotEqual(geteuid(), file.owner)
        XCTAssertEqual(testGID, file.group)
        XCTAssertNotEqual(getegid(), file.group)

        try? file.delete()
    }

    func testSetNeither() {
        var file: FilePath
        do {
            file = try FilePath.temporary(prefix: "com.trailblazer.test.").path
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        XCTAssertNoThrow(try file.change(owner: nil, group: nil))
        XCTAssertEqual(geteuid(), file.owner)
        XCTAssertEqual(0, file.group)

        try? file.delete()
    }

    func testSetOpen() {
        // Can't set the owner unless you're a privileged user, like root (uid == 0)
        // Can't set the group unless you're a privileged user, like root (uid
        // == 0) or if youre changing the group to one of the groups you are a
        // part of (too much work to get the list of groups the process's user
        // is a part of)
        guard geteuid() == 0 else { return }

        var openFile: Open<FilePath>
        do {
            openFile = try FilePath.temporary(prefix: "com.trailblazer.test.")
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        XCTAssertNoThrow(try openFile.change(owner: testUID, group: testGID))
        XCTAssertEqual(testUID, openFile.owner)
        XCTAssertNotEqual(geteuid(), openFile.owner)
        XCTAssertEqual(testGID, openFile.group)
        XCTAssertNotEqual(getegid(), openFile.group)

        try? openFile.delete()
    }

    func testSetRecursive() {
        #if os(Linux)
        let base: DirectoryPath = DirectoryPath.home!
        #else
        let base: DirectoryPath = DirectoryPath("/tmp")!
        #endif

        guard let dir = DirectoryPath(base + "\(UUID())") else {
            XCTFail("Test path exists and is not a directory")
            return
        }
        XCTAssertFalse(dir.exists)

        guard let file = FilePath(dir + "\(UUID())" + "\(UUID()).test") else {
            XCTFail("Test path exists and is not a file")
            return
        }

        let _ = try? file.create(options: .createIntermediates)

        do {
            var open = try dir.open()
            XCTAssertNoThrow(try open.changeRecursive(owner: open.ownerName, group: open.groupName))
        } catch {
            XCTFail("Failed to open directory with error \(type(of: error))(\(error))")
        }

        try? dir.recursiveDelete()
    }
}
