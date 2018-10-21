import XCTest
@testable import TrailBlazer

class MoveTests: XCTestCase {
    func testMove() {
        guard let home: DirectoryPath = .home else {
            return XCTFail("Failed to get the home directory")
        }
        guard var file = FilePath(home + "\(UUID()).test") else {
            return XCTFail("Path is not a file")
        }

        do {
            try file.create(mode: .ownerGroupOthers(.readWriteExecute))
        } catch {
            return XCTFail("Failed to create test path => \(file)")
        }

        let original = FilePath(file)

        XCTAssertNoThrow(try file.move(to: file.parent + UUID().description))

        XCTAssertNotEqual(file, original)
        XCTAssertEqual(file.parent, original.parent)

        try? file.delete()
    }

    func testRename() {
        guard let home: DirectoryPath = .home else {
            return XCTFail("Failed to get the home directory")
        }
        guard var file = FilePath(home + "\(UUID()).test") else {
            return XCTFail("Path is not a file")
        }

        do {
            try file.create(mode: .ownerGroupOthers(.readWriteExecute))
        } catch {
            return XCTFail("Failed to create test path => \(file)")
        }

        let original = FilePath(file)

        XCTAssertNoThrow(try file.rename(to: UUID().description))

        XCTAssertNotEqual(file, original)
        XCTAssertEqual(file.parent, original.parent)

        try? file.delete()
    }

    func testMoveInto() {
        guard let home: DirectoryPath = .home else {
            return XCTFail("Failed to get the home directory")
        }
        guard var file = FilePath(home + "\(UUID()).test") else {
            return XCTFail("Path is not a file")
        }
        guard var newDir = DirectoryPath(home + "\(UUID()).testdir") else {
            return XCTFail("Path is not a directory")
        }

        do {
            try file.create(mode: .ownerGroupOthers(.readWriteExecute))
            try newDir.create(mode: .ownerGroupOthers(.readWriteExecute))
        } catch {
            return XCTFail("Failed to create test path")
        }

        let original = FilePath(file)

        XCTAssertNoThrow(try file.move(into: newDir))

        XCTAssertEqual(original.lastComponent, file.lastComponent)
        XCTAssertNotEqual(original, file)
        XCTAssertNotEqual(original.parent, file.parent)
        XCTAssertEqual(file.parent, newDir)

        try? file.delete()
        try? newDir.delete()
    }
}
