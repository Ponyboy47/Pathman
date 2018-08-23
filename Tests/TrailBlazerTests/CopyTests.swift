import Foundation
import XCTest
@testable import TrailBlazer

class CopyTests: XCTestCase {
    func testCopyFile() {
        let tmpFile: OpenFile
        do {
            tmpFile = try FilePath.temporary(prefix: "com.trailblazer.copy.")
        } catch {
            XCTFail("Failed to create temporary file for copying with error: \(error)")
            return
        }

        XCTAssertNoThrow(try tmpFile.write("Hello world"))

        let newPath = FilePath(tmpFile.path.parent + "com.trailblazer.copied.\(UUID())")!

        let newOpenPath: OpenFile
        do {
            XCTAssertFalse(newPath.exists)
            newOpenPath = try tmpFile.copy(to: newPath)
        } catch {
            XCTFail("Failed to copy the path: \(type(of: error)).\(error)")
            try? tmpFile.delete()
            return
        }

        do {
            let originalContents = try tmpFile.read(from: .beginning)
            let copyContents = try newOpenPath.read(from: .beginning)
            XCTAssertEqual(originalContents, copyContents)
        } catch {
            XCTFail("Failed to read path with error: \(type(of: error)).\(error)")
        }

        try? tmpFile.delete()
        try? newOpenPath.delete()
    }

    func testCopyDirectoryEmpty() {
        let tmpDirectory: OpenDirectory
        do {
            tmpDirectory = try DirectoryPath.temporary(prefix: "com.trailblazer.copy.")
        } catch {
            XCTFail("Failed to create temporary directory for copying with error: \(error)")
            return
        }

        let newPath = DirectoryPath(tmpDirectory.path.parent + "com.trailblazer.copied.\(UUID())")!
        XCTAssertFalse(newPath.exists)
        XCTAssertNoThrow(try tmpDirectory.copy(to: newPath))
        XCTAssertTrue(newPath.exists)

        try? tmpDirectory.delete()
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

        let tmpFile: OpenFile
        do {
            tmpFile = try FilePath.temporary()
            try tmpFile.path.move(into: tmpDirectory.path)
        } catch {
            XCTFail("Failed to create/move temporary file into the temporary directory")
            return
        }

        let newPath = DirectoryPath(tmpDirectory.path.parent + "com.trailblazer.copied.\(UUID())")!
        do {
            try tmpDirectory.copy(to: newPath)
            XCTFail("Should not be able to copy non empty directory without the .recursive option")
        } catch CopyError.nonEmptyDirectory {
        } catch {
            XCTFail("Expected CopyError.nonEmptyDirectory received \(type(of: error)).\(error)")
        }


        try? tmpDirectory.recursiveDelete()
    }

    func testCopyDirectoryRecursive() {
    }

    static var allTests = [
        // ("testCopyFile", testCopyFile),
        ("testCopyDirectoryEmpty", testCopyDirectoryEmpty),
        ("testCopyDirectoryNotEmpty", testCopyDirectoryNotEmpty),
    ]
}

