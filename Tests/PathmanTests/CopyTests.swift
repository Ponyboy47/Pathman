import Foundation
@testable import Pathman
import XCTest

class CopyTests: XCTestCase {
    func testCopyFile() {
        let tmpFile: FileStream
        do {
            tmpFile = try FilePath.temporary(prefix: "com.trailblazer.copy.")
        } catch {
            XCTFail("Failed to create temporary file for copying with error: \(error)")
            return
        }
        var tmpPath = tmpFile.path

        XCTAssertNoThrow(try tmpFile.write("Hello world"))
        XCTAssertNoThrow(try tmpFile.flush())

        var newPath = FilePath(tmpFile.path.parent + "com.trailblazer.copied.\(UUID())")

        let newOpenPath: FileStream
        do {
            XCTAssertFalse(newPath.exists)
            newOpenPath = try tmpFile.copy(to: &newPath)
            XCTAssertNoThrow(try newOpenPath.flush())
            XCTAssertTrue(newPath.exists)
            XCTAssertEqual(newPath.size, tmpFile.size)
        } catch {
            XCTFail("Failed to copy the path: \(type(of: error)).\(error)")
            try? tmpPath.delete()
            try? newPath.delete()
            return
        }

        do {
            let originalContents = try tmpFile.read(from: .beginning)
            let copyContents = try newOpenPath.read(from: .beginning)
            XCTAssertEqual(originalContents, copyContents)
        } catch {
            XCTFail("Failed to read path with error: \(type(of: error)).\(error)")
        }

        try? tmpPath.delete()
        try? newPath.delete()
    }

    func testCopyDirectoryEmpty() {
        let tmpDirectory: OpenDirectory
        do {
            tmpDirectory = try DirectoryPath.temporary(prefix: "com.trailblazer.copy.")
        } catch {
            XCTFail("Failed to create temporary directory for copying with error: \(error)")
            return
        }

        var newPath = DirectoryPath(tmpDirectory.path.parent + "com.trailblazer.copied.\(UUID())")
        XCTAssertFalse(newPath.exists)
        XCTAssertNoThrow(try tmpDirectory.copy(to: &newPath))
        XCTAssertTrue(newPath.exists)

        var tmpPath = tmpDirectory.path
        try? tmpPath.delete()
        try? newPath.delete()
    }

    func testCopyDirectoryNotEmpty() {
        let tmpDirectory: OpenDirectory
        do {
            tmpDirectory = try DirectoryPath.temporary(prefix: "com.trailblazer.copy.")
        } catch {
            XCTFail("Failed to create temporary directory for copying with error: \(error)")
            return
        }

        let tmpFile: FileStream
        do {
            tmpFile = try FilePath.temporary()
            var path = tmpFile.path
            try path.move(into: tmpDirectory.path)
        } catch {
            XCTFail("Failed to create/move temporary file into the temporary directory")
            return
        }

        var newPath = DirectoryPath(tmpDirectory.path.parent + "com.trailblazer.copied.\(UUID())")
        do {
            try tmpDirectory.copy(to: &newPath)
            XCTFail("Should not be able to copy non empty directory without the .recursive option")
        } catch CopyError.nonEmptyDirectory {} catch {
            XCTFail("Expected CopyError.nonEmptyDirectory received \(type(of: error)).\(error)")
        }

        var dir = tmpDirectory.path
        try? dir.recursiveDelete()
        try? newPath.recursiveDelete()
    }

    func testCopyDirectoryRecursive() {
        let tmpDirectory: OpenDirectory
        do {
            tmpDirectory = try DirectoryPath.temporary(prefix: "com.trailblazer.copy.")
        } catch {
            XCTFail("Failed to create temporary directory for copying with error: \(error)")
            return
        }

        do {
            var tmpFile = try FilePath.temporary().path
            try tmpFile.move(into: tmpDirectory.path)
            var tmpDir = try DirectoryPath.temporary().path
            try tmpDir.move(into: tmpDirectory.path)
        } catch {
            XCTFail("Failed to create/move temporary file into the temporary directory")
            return
        }

        var newPath = DirectoryPath(tmpDirectory.path.parent + "com.trailblazer.copied.\(UUID())")
        XCTAssertNoThrow(try tmpDirectory.copy(to: &newPath, options: .recursive))

        var dir = tmpDirectory.path
        try? dir.recursiveDelete()
        try? newPath.recursiveDelete()
    }
}
