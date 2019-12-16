import Foundation
@testable import Pathman
import XCTest

#if os(Linux)
import Glibc
#else
import Darwin
#endif

class ChmodTests: XCTestCase {
    func testSetOwner() {
        let home: DirectoryPath! = .home
        var directory = DirectoryPath(home + "\(UUID()).test")

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(owner: .readWrite))
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
        let home: DirectoryPath! = .home
        var directory = DirectoryPath(home + "\(UUID()).test")

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(group: .readWrite))
        XCTAssertNoThrow(try directory.changeRecursive(group: .readWrite))

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
        let home: DirectoryPath! = .home
        var directory = DirectoryPath(home + "\(UUID()).test")

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(others: .readWrite))
        XCTAssertNoThrow(try directory.changeRecursive(others: .readWrite))

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
        let home: DirectoryPath! = .home
        var directory = DirectoryPath(home + "\(UUID()).test")

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(ownerGroup: .readWrite))
        XCTAssertNoThrow(try directory.changeRecursive(ownerGroup: .readWrite))

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
        let home: DirectoryPath! = .home
        var directory = DirectoryPath(home + "\(UUID()).test")

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(ownerOthers: .readWrite))
        XCTAssertNoThrow(try directory.changeRecursive(ownerOthers: .readWrite))

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
        let home: DirectoryPath! = .home
        var directory = DirectoryPath(home + "\(UUID()).test")

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(groupOthers: .readWrite))
        XCTAssertNoThrow(try directory.changeRecursive(groupOthers: .readWrite))

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
        let home: DirectoryPath! = .home
        var directory = DirectoryPath(home + "\(UUID()).test")

        if !directory.exists {
            do {
                try directory.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(directory)")
                return
            }
        }

        XCTAssertNoThrow(try directory.change(ownerGroupOthers: .readWrite))
        XCTAssertNoThrow(try directory.changeRecursive(ownerGroupOthers: .readWrite))

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
        let home: DirectoryPath! = .home
        var directory = DirectoryPath(home + "\(UUID()).test")

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
        let home: DirectoryPath! = .home
        var file = FilePath(home + "\(UUID()).test")

        let openFile: FileStream
        if !file.exists {
            do {
                openFile = try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            } catch {
                XCTFail("Failed to create test path => \(file)\n\(error)")
                return
            }
        } else {
            do {
                openFile = try file.open(mode: .readPlus)
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

    func testRecursive() {
        #if os(Linux)
        let base: DirectoryPath = DirectoryPath.home!
        #else
        let base: DirectoryPath = DirectoryPath("/tmp")
        #endif

        var dir = DirectoryPath(base + "\(UUID())")
        XCTAssertFalse(dir.exists)

        let parent = DirectoryPath(dir + "\(UUID())")
        var file = FilePath(parent + "\(UUID()).test")

        _ = try? file.create(options: .createIntermediates)

        do {
            var open = try dir.open()
            XCTAssertNoThrow(try open.changeRecursive(owner: .all))
        } catch {
            XCTFail("Failed to open directory with error \(type(of: error))(\(error))")
        }

        try? dir.recursiveDelete()
    }
}
