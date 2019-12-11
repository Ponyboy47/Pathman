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
        guard var file = FilePath(base + "\(UUID()).test") else {
            XCTFail("Test path exists and is not a file")
            return
        }

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
        guard var file = FilePath(base + "\(UUID()).test") else {
            XCTFail("Test path exists and is not a file")
            return
        }

        do {
            try file.create()
        } catch {
            XCTFail("Failed to create test file with error \(error)")
            return
        }

        XCTAssertNoThrow(try file.delete())
    }

    func testCreateDirectory() {
        guard var dir = DirectoryPath(base + "\(UUID())") else {
            XCTFail("Test path exists and is not a directory")
            return
        }

        XCTAssertNoThrow(try dir.create())
        XCTAssertTrue(dir.exists)
        XCTAssertTrue(dir.isDirectory)

        try? dir.delete()
    }

    func testDeleteDirectory() {
        guard var dir = DirectoryPath(base + "\(UUID())") else {
            XCTFail("Test path exists and is not a directory")
            return
        }

        do {
            try dir.create()
        } catch {
            XCTFail("Failed to create test directory with error \(error)")
            return
        }

        XCTAssertNoThrow(try dir.delete())
    }

    func testDeleteNonEmptyDirectory() {
        guard var dir = DirectoryPath(base + "\(UUID())") else {
            XCTFail("Test path exists and is not a directory")
            return
        }

        do {
            try dir.create()
        } catch {
            XCTFail("Failed to create test directory with error \(error)")
            return
        }

        for num in 1...10 {
            guard var file = FilePath(dir + "\(num).test") else {
                XCTFail("Test path exists and is not a file")
                return
            }

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
        guard var dir = DirectoryPath(base + "\(UUID())") else {
            XCTFail("Test path exists and is not a directory")
            return
        }

        do {
            try dir.create()
        } catch {
            XCTFail("Failed to create test directory with error \(error)")
            return
        }

        for num in 1...10 {
            guard var file = FilePath(dir + "\(num).test") else {
                XCTFail("Test path exists and is not a file")
                return
            }

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
        guard var dir = DirectoryPath(base + "\(UUID())") else {
            XCTFail("Test path exists and is not a directory")
            return
        }
        XCTAssertFalse(dir.exists)

        guard let parent = DirectoryPath(dir + "\(UUID())"), var file = FilePath(parent + "\(UUID()).test") else {
            XCTFail("Test path exists and is not a file")
            return
        }

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
        guard var file = FilePath(base + "\(UUID()).test") else {
            XCTFail("Test path exists and is not a file")
            return
        }

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
        guard var file = FilePath(base + "\(UUID()).test") else {
            XCTFail("Test path exists and is not a file")
            return
        }

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
