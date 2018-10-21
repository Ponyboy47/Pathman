import XCTest
#if os(Linux)
import Glibc
#else
import Darwin
#endif
@testable import TrailBlazer

class PathTests: XCTestCase {
    func testStringInit() {
        XCTAssertEqual(GenericPath("/tmp/").string, "/tmp")
        let dir = DirectoryPath("/tmp")
        XCTAssertNotNil(dir)
        XCTAssertEqual(dir!.string, "/tmp")
        let file = FilePath("/tmp/flabbergasted/")
        XCTAssertNotNil(file)
        XCTAssertEqual(file!.string, "/tmp/flabbergasted")
    }

    func testPathInit() {
        XCTAssertEqual(GenericPath(GenericPath("/tmp")).string, "/tmp")
        XCTAssertEqual(GenericPath(DirectoryPath("/tmp")!).string, "/tmp")
        XCTAssertEqual(GenericPath(FilePath("/tmp/flabbergasted")!).string, "/tmp/flabbergasted")

        XCTAssertEqual(DirectoryPath(GenericPath("/tmp"))!.string, "/tmp")
        XCTAssertEqual(DirectoryPath(DirectoryPath("/tmp")!).string, "/tmp")
        // Disallowed now
        // XCTAssertNil(DirectoryPath(FilePath("/tmp/flabbergasted")!))

        XCTAssertEqual(FilePath(GenericPath("/tmp/flabbergasted"))!.string, "/tmp/flabbergasted")
        // Disallowed now
        // XCTAssertNil(FilePath(DirectoryPath("/tmp")!))
        XCTAssertEqual(FilePath(FilePath("/tmp/flabbergasted")!).string, "/tmp/flabbergasted")
    }

    func testVariadicInit() {
        XCTAssertEqual(GenericPath("/", "tmp").string, "/tmp")
        XCTAssertEqual(DirectoryPath("/", "tmp")!.string, "/tmp")
        XCTAssertEqual(FilePath("/", "tmp", "flabbergasted")!.string, "/tmp/flabbergasted")
    }

    func testArrayInit() {
        XCTAssertEqual(GenericPath(["/", "tmp"]).string, "/tmp")
        XCTAssertEqual(DirectoryPath(["/", "tmp"])!.string, "/tmp")
        XCTAssertEqual(FilePath(["/", "tmp", "flabbergasted"])!.string, "/tmp/flabbergasted")
        XCTAssertNil(FilePath(["/", "tmp"]))
    }

    func testArraySliceInit() {
        XCTAssertEqual(GenericPath(["/", "tmp", "test"].dropLast()).string, "/tmp")
        XCTAssertEqual(DirectoryPath(["/", "tmp", "test"].dropLast())!.string, "/tmp")
        XCTAssertEqual(FilePath(["/", "tmp", "flabbergasted", "other"].dropLast())!.string, "/tmp/flabbergasted")
    }

    func testStringLiteral() {
        let path1: GenericPath = "/tmp"
        let path2: GenericPath = "/tmp/"
        XCTAssertEqual(path1.string, "/tmp")
        XCTAssertEqual(path1, path2)
    }

    func testArrayLiteral() {
        let path1: GenericPath = ["/", "tmp"]
        XCTAssertEqual(path1.string, "/tmp")
    }

    func testChRoot() {
        let directory = DirectoryPath()!
        XCTAssertEqual(DirectoryPath.root.string, "/")
        XCTAssertEqual(directory.root.string, "/")

        DirectoryPath.root = DirectoryPath("/tmp")!
        directory.root = DirectoryPath("/tmp")!
        if (geteuid() == 0) {
            XCTAssertEqual(DirectoryPath.root.string, "/tmp")
            XCTAssertEqual(directory.root.string, "/tmp")
            DirectoryPath.root = DirectoryPath("/")!
            directory.root = DirectoryPath("/")!
        }
        XCTAssertEqual(DirectoryPath.root.string, "/")
        XCTAssertEqual(directory.root.string, "/")
    }

    func testChCWD() {
        let directory = DirectoryPath()!
        DirectoryPath.cwd = DirectoryPath("/tmp")!
        directory.cwd = DirectoryPath("/tmp")!
        XCTAssertEqual(DirectoryPath.cwd.string, "/tmp")
        XCTAssertEqual(directory.cwd.string, "/tmp")
        DirectoryPath.cwd = DirectoryPath("/")!
        directory.cwd = DirectoryPath("/")!
        XCTAssertEqual(DirectoryPath.cwd.string, "/")
        XCTAssertEqual(directory.cwd.string, "/")
    }

    func testComponents() {
        XCTAssertEqual(GenericPath("/tmp").components, ["/", "tmp"])
        XCTAssertEqual(DirectoryPath("/tmp")!.components, ["/", "tmp"])
        XCTAssertEqual(FilePath("/tmp/flabbergasted")!.components, ["/", "tmp", "flabbergasted"])
    }

    func testLastComponent() {
        XCTAssertEqual(GenericPath("/tmp").lastComponent, "tmp")
        XCTAssertEqual(DirectoryPath("/tmp")!.lastComponent, "tmp")
        XCTAssertEqual(FilePath("/tmp/flabbergasted.test")!.lastComponent, "flabbergasted.test")
    }

    func testLastComponentWithoutExtension() {
        XCTAssertEqual(FilePath("/tmp/flabbergasted.test")!.lastComponentWithoutExtension, "flabbergasted")
    }

    func testParent() {
        let dir = DirectoryPath("/tmp")!
        XCTAssertEqual(GenericPath("/tmp").parent.string, "/")
        XCTAssertEqual(dir.parent.string, "/")
        XCTAssertEqual(dir.parent.parent.string, "/")
        XCTAssertEqual(FilePath("flabbergasted/whatever")!.parent.parent.string, FilePath.cwd.string)
    }

    func testSetParent() {
        let dir = DirectoryPath("/tmp")!
        do {
            var testPath = try FilePath.temporary(prefix: "com.trailblazer.test.").path
            testPath.parent = dir
            XCTAssertEqual(testPath.parent, dir)
            try? testPath.delete()
        } catch {
            XCTFail("Failed to create test path")
        }
    }

    func testExists() {
        XCTAssertTrue(DirectoryPath("/tmp")!.exists)
        XCTAssertTrue(GenericPath.root.exists)
        XCTAssertTrue(DirectoryPath.cwd.exists)
        // If this path actually exists...I don't even know...
        XCTAssertFalse(DirectoryPath("/aneriuflaer/faeirgoait")!.exists)
    }

    func testCustomStringConvertible() {
        let path1 = GenericPath("/tmp")
        let path2 = DirectoryPath("/tmp")!
        let path3 = FilePath("/tmp/flabbergasted")!
        XCTAssertEqual(path1.description, "GenericPath(\"/tmp\")")
        XCTAssertEqual(path2.description, "DirectoryPath(\"/tmp\")")
        XCTAssertEqual(path3.description, "FilePath(\"/tmp/flabbergasted\")")
    }

    func testEquatable() {
        XCTAssertEqual(GenericPath("/tmp"), GenericPath("/tmp"))
        XCTAssertTrue(GenericPath("/tmp") == DirectoryPath("/tmp")!)

        XCTAssertFalse(DirectoryPath("/tmp")! == FilePath("/tmp/flabbergasted")!)
    }

    func testAddable() {
        var path1: DirectoryPath = DirectoryPath("/")!
        let path2: DirectoryPath = DirectoryPath("tmp")!
        let path3: DirectoryPath = DirectoryPath("test")!
        let path4: FilePath = FilePath("flabbergasted")!

        let testPath1 = path1 + path2
        let testPath2 = path1 + path2 + path3
        let testPath3 = path1 + path2 + path4

        path1 += path2
        let testPath4 = path1 + path4

        XCTAssertEqual(testPath1.string, "/tmp")
        XCTAssertEqual(testPath2.string, "/tmp/test")
        XCTAssertEqual(testPath3.string, "/tmp/flabbergasted")
        XCTAssertEqual(testPath4.string, "/tmp/flabbergasted")
    }

    func testAbsolute() {
        let relative1 = GenericPath("~/")
        let relative2 = DirectoryPath("~/../")!
        let relative3 = FilePath("~/flabbergasted/.")!

        XCTAssertFalse(relative1.isAbsolute)
        XCTAssertNotEqual(relative1, relative1.absolute)
        XCTAssertNotEqual(relative2, relative2.absolute)
        XCTAssertNotEqual(relative3, relative3.absolute)
        XCTAssertTrue(relative1.absolute?.isAbsolute ?? true)
    }

    func testExpand() {
        var relative1 = GenericPath("~/")
        let relative2 = GenericPath("~/")

        XCTAssertFalse(relative1.exists)
        XCTAssertNoThrow(try relative1.expand())
        XCTAssertTrue(relative1.exists)
        XCTAssertEqual(try! relative2.expanded(), relative1)
    }

    func testRelative() {
        let relative1 = GenericPath("~/")
        let relative2 = DirectoryPath("./")!
        let relative3 = FilePath("../flabbergasted")!
        let absolute = FilePath.cwd + FilePath("flabbergasted2")!

        XCTAssertTrue(relative1.isRelative)
        XCTAssertTrue(relative2.isRelative)
        XCTAssertTrue(relative3.isRelative)
        XCTAssertEqual(relative1, relative1.absolute?.relative ?? relative1)
        XCTAssertNotEqual(absolute.relative, absolute)
    }

    func testPathType() {
        guard let dir = DirectoryPath("/tmp") else {
            XCTFail("/tmp is not a directory")
            return
        }

        guard let pathType = PathType(mode: dir.permissions) else {
            XCTFail("pathType was nil for \(dir.permissions)")
            return
        }
        XCTAssertEqual(pathType, .directory)
    }

    func testGenericPathMath() {
        let path1: GenericPath = "/tmp"
        var path2: GenericPath = "/tmp"

        XCTAssertEqual(path1 + path2, "/tmp/tmp")
        XCTAssertEqual(path1.string + path2, "/tmp/tmp")
        XCTAssertEqual(path1 + "/tmp", "/tmp/tmp")

        path2 += path1
        XCTAssertEqual(path2, "/tmp/tmp")
        path2 = path1
        path2 += "/tmp"
        XCTAssertEqual(path2, "/tmp/tmp")
    }

    func testGetHome() {
        XCTAssertNoThrow(try getHome(username: "root"))
        #if os(macOS)
        XCTAssertNoThrow(try getGroupInfo(groupname: "admin"))
        #else
        XCTAssertNoThrow(try getGroupInfo(groupname: "root"))
        #endif
        XCTAssertNoThrow(try getGroupInfo(gid: 0))
    }

    func testIsLink() {
        guard let dir = DirectoryPath("/tmp") else {
            XCTFail("/tmp is not a directory")
            return
        }

        #if os(macOS)
        XCTAssertTrue(dir.isLink)
        #else
        XCTAssertFalse(dir.isLink)
        #endif
    }

    func testIterator() {
        let path = FilePath("/path/to/test/location")!
        let pieces = path.components
        for (idx, piece) in path.enumerated() {
            XCTAssertEqual(piece, pieces[idx])
        }
    }
}
