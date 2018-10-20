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
        guard var directory = DirectoryPath(home + "\(UUID()).test") else {
            XCTFail("Path is not a directory")
            return
        }

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.changeRecursive(owner: .readWrite))

        let permissions = directory.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.isReadable)
        XCTAssertTrue(owner.isWritable)
        XCTAssertFalse(owner.isExecutable)

        let group = permissions.group
        XCTAssertTrue(group.isReadable)
        XCTAssertTrue(group.isWritable)
        XCTAssertTrue(group.isExecutable)

        let others = permissions.others
        XCTAssertTrue(others.isReadable)
        XCTAssertTrue(others.isWritable)
        XCTAssertTrue(others.isExecutable)

        try? directory.delete()
    }

    func testSetGroup() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard var directory = DirectoryPath(home + "\(UUID()).test") else {
            XCTFail("Path is not a directory")
            return
        }

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(group: .readWrite))

        let permissions = directory.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.isReadable)
        XCTAssertTrue(owner.isWritable)
        XCTAssertTrue(owner.isExecutable)

        let group = permissions.group
        XCTAssertTrue(group.isReadable)
        XCTAssertTrue(group.isWritable)
        XCTAssertFalse(group.isExecutable)

        let others = permissions.others
        XCTAssertTrue(others.isReadable)
        XCTAssertTrue(others.isWritable)
        XCTAssertTrue(others.isExecutable)

        try? directory.delete()
    }

    func testSetOthers() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard var directory = DirectoryPath(home + "\(UUID()).test") else {
            XCTFail("Path is not a directory")
            return
        }

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(others: .readWrite))

        let permissions = directory.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.isReadable)
        XCTAssertTrue(owner.isWritable)
        XCTAssertTrue(owner.isExecutable)

        let group = permissions.group
        XCTAssertTrue(group.isReadable)
        XCTAssertTrue(group.isWritable)
        XCTAssertTrue(group.isExecutable)

        let others = permissions.others
        XCTAssertTrue(others.isReadable)
        XCTAssertTrue(others.isWritable)
        XCTAssertFalse(others.isExecutable)

        try? directory.delete()
    }

    func testSetOwnerGroup() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard var directory = DirectoryPath(home + "\(UUID()).test") else {
            XCTFail("Path is not a directory")
            return
        }

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(ownerGroup: .readWrite))

        let permissions = directory.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.isReadable)
        XCTAssertTrue(owner.isWritable)
        XCTAssertFalse(owner.isExecutable)

        let group = permissions.group
        XCTAssertTrue(group.isReadable)
        XCTAssertTrue(group.isWritable)
        XCTAssertFalse(group.isExecutable)

        let others = permissions.others
        XCTAssertTrue(others.isReadable)
        // XCTAssertTrue(others.isWritable)
        XCTAssertTrue(others.isExecutable)

        try? directory.delete()
    }

    func testSetOwnerOthers() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard var directory = DirectoryPath(home + "\(UUID()).test") else {
            XCTFail("Path is not a directory")
            return
        }

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(ownerOthers: .readWrite))

        let permissions = directory.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.isReadable)
        XCTAssertTrue(owner.isWritable)
        XCTAssertFalse(owner.isExecutable)

        let group = permissions.group
        XCTAssertTrue(group.isReadable)
        XCTAssertTrue(group.isWritable)
        XCTAssertTrue(group.isExecutable)

        let others = permissions.others
        XCTAssertTrue(others.isReadable)
        XCTAssertTrue(others.isWritable)
        XCTAssertFalse(others.isExecutable)

        try? directory.delete()
    }

    func testSetGroupOthers() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard var directory = DirectoryPath(home + "\(UUID()).test") else {
            XCTFail("Path is not a directory")
            return
        }

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(groupOthers: .readWrite))

        let permissions = directory.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.isReadable)
        XCTAssertTrue(owner.isWritable)
        XCTAssertTrue(owner.isExecutable)

        let group = permissions.group
        XCTAssertTrue(group.isReadable)
        XCTAssertTrue(group.isWritable)
        XCTAssertFalse(group.isExecutable)

        let others = permissions.others
        XCTAssertTrue(others.isReadable)
        XCTAssertTrue(others.isWritable)
        XCTAssertFalse(others.isExecutable)

        try? directory.delete()
    }

    func testSetOwnerGroupOthers() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard var directory = DirectoryPath(home + "\(UUID()).test") else {
            XCTFail("Path is not a directory")
            return
        }

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(ownerGroupOthers: .readWrite))

        let permissions = directory.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.isReadable)
        XCTAssertTrue(owner.isWritable)
        XCTAssertFalse(owner.isExecutable)

        let group = permissions.group
        XCTAssertTrue(group.isReadable)
        XCTAssertTrue(group.isWritable)
        XCTAssertFalse(group.isExecutable)

        let others = permissions.others
        XCTAssertTrue(others.isReadable)
        XCTAssertTrue(others.isWritable)
        XCTAssertFalse(others.isExecutable)

        try? directory.delete()
    }

    func testSetProperties() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard var directory = DirectoryPath(home + "\(UUID()).test") else {
            XCTFail("Path is not a directory")
            return
        }

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        directory.permissions.owner = .readWrite
        directory.permissions.group = .readWrite
        directory.permissions.others = .readWrite

        let permissions = directory.permissions

        let owner = permissions.owner
        XCTAssertTrue(owner.isReadable)
        XCTAssertTrue(owner.isWritable)
        XCTAssertFalse(owner.isExecutable)

        let group = permissions.group
        XCTAssertTrue(group.isReadable)
        XCTAssertTrue(group.isWritable)
        XCTAssertFalse(group.isExecutable)

        let others = permissions.others
        XCTAssertTrue(others.isReadable)
        XCTAssertTrue(others.isWritable)
        XCTAssertFalse(others.isExecutable)

        try? directory.delete()
    }

    func testOpenFile() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard let file = FilePath(home + "\(UUID()).test") else {
            XCTFail("Path is not a directory")
            return
        }

        let openFile: OpenFile
        if !file.exists {
            do {
                openFile = try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)")
                return
            }
        } else {
            do {
                openFile = try file.open(permissions: .readWrite)
            } catch {
                XCTFail("Failed to open test path => \(file)")
                return
            }
        }

        XCTAssertNoThrow(try openFile.change(others: .read))
        XCTAssertEqual(openFile.permissions.owner & openFile.permissions.group, .readWriteExecute)
        XCTAssertEqual(openFile.permissions.others, .read)

        try? file.delete()
    }
}

