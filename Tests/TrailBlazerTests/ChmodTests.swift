import XCTest
import Foundation
@testable import TrailBlazer

#if os(Linux)
import Glibc
#else
import Darwin
#endif

class ChmodTests: XCTestCase {
    func testSetOwner() {
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
                try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(owner: .readWrite))

        let permissions = file.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.canRead)
        XCTAssertTrue(owner.canWrite)
        XCTAssertFalse(owner.canExecute)

        let group = permissions.group
        XCTAssertTrue(group.canRead)
        XCTAssertTrue(group.canWrite)
        XCTAssertTrue(group.canExecute)

        let others = permissions.others
        XCTAssertTrue(others.canRead)
        // XCTAssertTrue(others.canWrite)
        XCTAssertTrue(others.canExecute)

        try? file.delete()
    }

    func testSetGroup() {
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
                try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(group: .readWrite))

        let permissions = file.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.canRead)
        XCTAssertTrue(owner.canWrite)
        XCTAssertTrue(owner.canExecute)

        let group = permissions.group
        XCTAssertTrue(group.canRead)
        XCTAssertTrue(group.canWrite)
        XCTAssertFalse(group.canExecute)

        let others = permissions.others
        XCTAssertTrue(others.canRead)
        // XCTAssertTrue(others.canWrite)
        XCTAssertTrue(others.canExecute)

        try? file.delete()
    }

    func testSetOthers() {
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
                try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(others: .readWrite))

        let permissions = file.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.canRead)
        XCTAssertTrue(owner.canWrite)
        XCTAssertTrue(owner.canExecute)

        let group = permissions.group
        XCTAssertTrue(group.canRead)
        XCTAssertTrue(group.canWrite)
        XCTAssertTrue(group.canExecute)

        let others = permissions.others
        XCTAssertTrue(others.canRead)
        XCTAssertTrue(others.canWrite)
        XCTAssertFalse(others.canExecute)

        try? file.delete()
    }

    func testSetOwnerGroup() {
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
                try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(ownerGroup: .readWrite))

        let permissions = file.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.canRead)
        XCTAssertTrue(owner.canWrite)
        XCTAssertFalse(owner.canExecute)

        let group = permissions.group
        XCTAssertTrue(group.canRead)
        XCTAssertTrue(group.canWrite)
        XCTAssertFalse(group.canExecute)

        let others = permissions.others
        XCTAssertTrue(others.canRead)
        // XCTAssertTrue(others.canWrite)
        XCTAssertTrue(others.canExecute)

        try? file.delete()
    }

    func testSetOwnerOthers() {
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
                try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(ownerOthers: .readWrite))

        let permissions = file.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.canRead)
        XCTAssertTrue(owner.canWrite)
        XCTAssertFalse(owner.canExecute)

        let group = permissions.group
        XCTAssertTrue(group.canRead)
        XCTAssertTrue(group.canWrite)
        XCTAssertTrue(group.canExecute)

        let others = permissions.others
        XCTAssertTrue(others.canRead)
        XCTAssertTrue(others.canWrite)
        XCTAssertFalse(others.canExecute)

        try? file.delete()
    }

    func testSetGroupOthers() {
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
                try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(groupOthers: .readWrite))

        let permissions = file.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.canRead)
        XCTAssertTrue(owner.canWrite)
        XCTAssertTrue(owner.canExecute)

        let group = permissions.group
        XCTAssertTrue(group.canRead)
        XCTAssertTrue(group.canWrite)
        XCTAssertFalse(group.canExecute)

        let others = permissions.others
        XCTAssertTrue(others.canRead)
        XCTAssertTrue(others.canWrite)
        XCTAssertFalse(others.canExecute)

        try? file.delete()
    }

    func testSetOwnerGroupOthers() {
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
                try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try file.change(ownerGroupOthers: .readWrite))

        let permissions = file.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.canRead)
        XCTAssertTrue(owner.canWrite)
        XCTAssertFalse(owner.canExecute)

        let group = permissions.group
        XCTAssertTrue(group.canRead)
        XCTAssertTrue(group.canWrite)
        XCTAssertFalse(group.canExecute)

        let others = permissions.others
        XCTAssertTrue(others.canRead)
        XCTAssertTrue(others.canWrite)
        XCTAssertFalse(others.canExecute)

        try? file.delete()
    }

    func testSetProperties() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard var file = FilePath(home + "\(UUID()).test") else {
            XCTFail("Path is not a file")
            return
        }

        if !file.exists {
            do {
                try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        }

        file.permissions.owner = .readWrite
        file.permissions.group = .readWrite
        file.permissions.others = .readWrite

        let permissions = file.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.canRead)
        XCTAssertTrue(owner.canWrite)
        XCTAssertFalse(owner.canExecute)

        let group = permissions.group
        XCTAssertTrue(group.canRead)
        XCTAssertTrue(group.canWrite)
        XCTAssertFalse(group.canExecute)

        let others = permissions.others
        XCTAssertTrue(others.canRead)
        XCTAssertTrue(others.canWrite)
        XCTAssertFalse(others.canExecute)

        try? file.delete()
    }

    static var allTests = [
        ("testSetOwner", testSetOwner),
        ("testSetGroup", testSetGroup),
        ("testSetOthers", testSetOthers),
        ("testSetOwnerGroup", testSetOwnerGroup),
        ("testSetOwnerOthers", testSetOwnerOthers),
        ("testSetGroupOthers", testSetGroupOthers),
        ("testSetOwnerGroupOthers", testSetOwnerGroupOthers),
        ("testSetProperties", testSetProperties),
    ]
}

