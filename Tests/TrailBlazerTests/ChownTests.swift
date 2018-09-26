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

        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard let file = FilePath(home + "\(UUID()).test") else {
            XCTFail("Path is not a file")
            return
        }

        if !file.exists {
            do {
                try file.create(mode: .ownerGroupOthers(.all))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(owner: testUID))
        XCTAssertEqual(testUID, file.owner)
        XCTAssertNotEqual(geteuid(), file.owner)
        XCTAssertEqual(getegid(), file.group)

        try? file.delete()
    }

    func testSetGroup() {
        // Can't set the group unless you're a privileged user, like root (uid
        // == 0) or if youre changing the group to one of the groups you are a
        // part of (too much work to get the list of groups the process's user
        // is a part of)
        guard geteuid() == 0 else { return }

        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard let file = FilePath(home + "\(UUID()).test") else {
            XCTFail("Path is not a file")
            return
        }

        if !file.exists {
            do {
                try file.create(mode: .ownerGroupOthers(.all))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(group: testGID))
        XCTAssertEqual(testGID, file.group)
        XCTAssertNotEqual(getegid(), file.group)
        XCTAssertEqual(geteuid(), file.owner)

        try? file.delete()
    }

    func testSetBoth() {
        // Can't set the owner unless you're a privileged user, like root (uid == 0)
        // Can't set the group unless you're a privileged user, like root (uid
        // == 0) or if youre changing the group to one of the groups you are a
        // part of (too much work to get the list of groups the process's user
        // is a part of)
        guard geteuid() == 0 else { return }

        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard let file = FilePath(home + "\(UUID()).test") else {
            XCTFail("Path is not a file")
            return
        }

        if !file.exists {
            do {
                try file.create(mode: .ownerGroupOthers(.all))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(owner: testUID, group: testGID))
        XCTAssertEqual(testUID, file.owner)
        XCTAssertNotEqual(geteuid(), file.owner)
        XCTAssertEqual(testGID, file.group)
        XCTAssertNotEqual(getegid(), file.group)

        try? file.delete()
    }

    func testSetNeither() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard let file = FilePath(home + "\(UUID()).test") else {
            XCTFail("Path is not a file")
            return
        }

        if !file.exists {
            do {
                try file.create(mode: .ownerGroupOthers(.all))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(owner: nil, group: nil))
        XCTAssertEqual(geteuid(), file.owner)
        XCTAssertEqual(getegid(), file.group)

        try? file.delete()
    }
}
