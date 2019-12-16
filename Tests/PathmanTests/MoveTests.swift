@testable import Pathman
import XCTest

class MoveTests: XCTestCase {
    func testMove() {
        let home: DirectoryPath! = .home
        var file = FilePath(home + "\(UUID()).test")

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
        let home: DirectoryPath! = .home
        var file = FilePath(home + "\(UUID()).test")

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
        let home: DirectoryPath! = .home
        var file = FilePath(home + "\(UUID()).test")
        var newDir = DirectoryPath(home + "\(UUID()).testdir")

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
