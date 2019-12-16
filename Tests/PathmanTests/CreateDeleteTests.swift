import Foundation
@testable import Pathman
import XCTest

class CreateDeleteTests: XCTestCase {
    private lazy var base: DirectoryPath = {
        #if os(Linux)
        return DirectoryPath.home!
        #else
        return DirectoryPath("/tmp")!
        #endif
    }()

    func testCreateFile() {
        var file = FilePath(base + "\(UUID()).test")

        do {
            let open = try file.create()
            XCTAssertTrue(file.exists)
            XCTAssertTrue(file.isFile)
            try! open.write("Hello World")
        } catch {
            XCTFail("Failed to create test file with error \(error)")
        }

        try? file.delete()
    }

    func testDeleteFile() {
        var file = FilePath(base + "\(UUID()).test")

        do {
            try file.create()
        } catch {
            XCTFail("Failed to create test file with error \(error)")
            return
        }

        XCTAssertNoThrow(try file.delete())
    }

    func testCreateDirectory() {
        var dir = DirectoryPath(base + "\(UUID())")

        XCTAssertNoThrow(try dir.create())
        XCTAssertTrue(dir.exists)
        XCTAssertTrue(dir.isDirectory)

        try? dir.delete()
    }

    func testDeleteDirectory() {
        var dir = DirectoryPath(base + "\(UUID())")

        do {
            try dir.create()
        } catch {
            XCTFail("Failed to create test directory with error \(error)")
            return
        }

        XCTAssertNoThrow(try dir.delete())
    }

    func testDeleteNonEmptyDirectory() {
        var dir = DirectoryPath(base + "\(UUID())")

        do {
            try dir.create()
        } catch {
            XCTFail("Failed to create test directory with error \(error)")
            return
        }

        for num in 1...10 {
            var file = FilePath(dir + "\(num).test")

            do {
                try file.create()
            } catch OpenFileError.pathExists {
                continue
            } catch {
                XCTFail("Failed to create test file with error \(error)")
                break
            }
        }

        do {
            try dir.delete()
            XCTFail("Did not fail to delete nonEmpty directory")
        } catch {}

        try? dir.recursiveDelete()
    }

    func testDeleteDirectoryRecursive() {
        var dir = DirectoryPath(base + "\(UUID())")

        do {
            try dir.create()
        } catch {
            XCTFail("Failed to create test directory with error \(error)")
            return
        }

        for num in 1...10 {
            var file = FilePath(dir + "\(num).test")

            do {
                try file.create()
            } catch OpenFileError.pathExists {
                continue
            } catch {
                XCTFail("Failed to create test file with error \(error)")
                break
            }
        }

        XCTAssertNoThrow(try dir.recursiveDelete())
    }

    func testCreateIntermediates() {
        var dir = DirectoryPath(base + "\(UUID())")
        XCTAssertFalse(dir.exists)

        let parent = DirectoryPath(dir + "\(UUID())")
        var file = FilePath(parent + "\(UUID()).test")

        do {
            let open = try file.create(options: .createIntermediates)
            XCTAssertTrue(file.exists)
            XCTAssertTrue(file.isFile)
            try open.write("Hello World")
        } catch {
            XCTFail("Failed to create/write to file with error \(type(of: error))(\(error))")
        }

        try? dir.recursiveDelete()
    }

    func testCreateWithContents() {
        var file = FilePath(base + "\(UUID()).test")

        do {
            try file.create(contents: "Hello World")
            XCTAssertTrue(file.exists)
            XCTAssertTrue(file.isFile)
            XCTAssertEqual(try! file.read(), "Hello World")
        } catch {
            XCTFail("Failed to create test file with error \(error)")
        }

        try? file.delete()
    }

    func testCreateWithClosure() {
        var file = FilePath(base + "\(UUID()).test")

        do {
            try file.create { openFile in
                XCTAssertTrue(openFile.exists)
                XCTAssertTrue(openFile.isFile)
                XCTAssertNoThrow(try openFile.write("Hello World"))
                XCTAssertEqual(try! openFile.read(from: .beginning), "Hello World")
            }
        } catch {
            XCTFail("Failed to create test file with error \(error)")
        }

        try? file.delete()
    }
}
