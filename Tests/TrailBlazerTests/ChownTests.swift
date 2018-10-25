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
        var file: FilePath
        do {
            file = try FilePath.temporary(prefix: "com.trailblazer.test.").path
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        file.owner = testUID
        XCTAssertNotNil(file.ownerName)

        // Can't set the owner unless you're a privileged user, like root (uid == 0)
        if geteuid() == 0 {
            XCTAssertEqual(testUID, file.owner)
            XCTAssertNotEqual(geteuid(), file.owner)
            XCTAssertEqual(getegid(), file.group)
        }

        try? file.delete()
    }

    func testSetGroup() {
        var file: FilePath
        do {
            file = try FilePath.temporary(prefix: "com.trailblazer.test.").path
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        file.group = testGID
        XCTAssertNotNil(file.groupName)

        if geteuid() == 0 {
            XCTAssertEqual(testGID, file.group)
            XCTAssertNotEqual(getegid(), file.group)
            XCTAssertEqual(geteuid(), file.owner)
        }

        try? file.delete()
    }

    func testSetBoth() {
        var file: FilePath
        do {
            file = try FilePath.temporary(prefix: "com.trailblazer.test.").path
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        if geteuid() == 0 {
            XCTAssertNoThrow(try file.change(owner: testUID, group: testGID))
            XCTAssertEqual(testUID, file.owner)
            XCTAssertNotEqual(geteuid(), file.owner)
            XCTAssertEqual(testGID, file.group)
            XCTAssertNotEqual(getegid(), file.group)
        }

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
        XCTAssertNotEqual(100, file.group) // group is 0 on mac, 2000 on travis linux, and whatever the current UID is on other linux OSes

        try? file.delete()
    }

    func testSetOpen() {
        var openFile: Open<FilePath>
        do {
            openFile = try FilePath.temporary(prefix: "com.trailblazer.test.")
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        if geteuid() == 0 {
            XCTAssertNoThrow(try openFile.change(owner: testUID, group: testGID))
            XCTAssertEqual(testUID, openFile.owner)
            XCTAssertNotEqual(geteuid(), openFile.owner)
            XCTAssertEqual(testGID, openFile.group)
            XCTAssertNotEqual(getegid(), openFile.group)
        }

        try? openFile.path.delete()
    }

    func testSetRecursive() {
        #if os(Linux)
        let base: DirectoryPath = DirectoryPath.home!
        #else
        let base: DirectoryPath = DirectoryPath("/tmp")!
        #endif

        guard var dir = DirectoryPath(base + "\(UUID())") else {
            XCTFail("Test path exists and is not a directory")
            return
        }
        XCTAssertFalse(dir.exists)

        guard var file = FilePath(dir + "\(UUID())" + "\(UUID()).test") else {
            XCTFail("Test path exists and is not a file")
            return
        }

        _ = try? file.create(options: .createIntermediates)

        do {
            var open = try dir.open()
            XCTAssertNoThrow(try open.changeRecursive(owner: open.ownerName, group: open.groupName))
            XCTAssertNoThrow(try open.changeRecursive(owner: open.ownerName))
            XCTAssertNoThrow(try open.changeRecursive(group: open.groupName))
        } catch {
            XCTFail("Failed to open directory with error \(type(of: error))(\(error))")
        }

        try? dir.recursiveDelete()
    }

    func testSetString() {
        var file: FilePath
        do {
            file = try FilePath.temporary(prefix: "com.trailblazer.test.").path
        } catch {
            XCTFail("Failed to create test path")
            return
        }

        file.ownerName = "root"
        file.groupName = "root"

        try? file.delete()
    }
}
