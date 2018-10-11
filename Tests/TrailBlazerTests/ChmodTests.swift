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

        XCTAssertNoThrow(try file.change(owner: .readWrite))

        let permissions = file.permissions

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

        try? file.delete()
    }

    func testSetGroup() {
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

        XCTAssertNoThrow(try file.change(group: .readWrite))

        let permissions = file.permissions

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

        try? file.delete()
    }

    func testSetOthers() {
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

        XCTAssertNoThrow(try file.change(others: .readWrite))

        let permissions = file.permissions

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

        try? file.delete()
    }

    func testSetOwnerGroup() {
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

        XCTAssertNoThrow(try file.change(ownerGroup: .readWrite))

        let permissions = file.permissions

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

        try? file.delete()
    }

    func testSetOwnerOthers() {
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

        XCTAssertNoThrow(try file.change(ownerOthers: .readWrite))

        let permissions = file.permissions

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

        try? file.delete()
    }

    func testSetGroupOthers() {
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

        XCTAssertNoThrow(try file.change(groupOthers: .readWrite))

        let permissions = file.permissions

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

        try? file.delete()
    }

    func testSetOwnerGroupOthers() {
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

        XCTAssertNoThrow(try file.change(ownerGroupOthers: .readWrite))

        let permissions = file.permissions

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

        try? file.delete()
    }

    func testOpenFile() {
        guard let home: DirectoryPath = .home else {
            XCTFail("Failed to get the home directory")
            return
        }
        guard let file = FilePath(home + "\(UUID()).test") else {
            XCTFail("Path is not a file")
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
    }
}

