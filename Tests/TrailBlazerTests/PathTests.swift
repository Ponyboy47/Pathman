import XCTest
#if os(Linux)
import Glibc
#else
import Darwin
#endif
@testable import TrailBlazer

class PathTests: XCTestCase {
    func testStringInit() {
        XCTAssertEqual(GenericPath("/tmp").string, "/tmp")
        guard let dir = DirectoryPath("/tmp") else {
            XCTFail("DirectoryPath was nil")
            return
        }
        XCTAssertEqual(dir.string, "/tmp")
        guard let file = FilePath("/tmp/flabbergasted") else {
            XCTFail("FilePath was nil")
            return
        }
        XCTAssertEqual(file.string, "/tmp/flabbergasted")
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

    func testArrayInit() {
        XCTAssertEqual(GenericPath(["/", "tmp"]).string, "/tmp")
        XCTAssertEqual(DirectoryPath(["/", "tmp"])!.string, "/tmp")
        XCTAssertEqual(FilePath(["/", "tmp", "flabbergasted"])!.string, "/tmp/flabbergasted")
    }

    func testArraySliceInit() {
        XCTAssertEqual(GenericPath(["/", "tmp", "test"].dropLast()).string, "/tmp")
        XCTAssertEqual(DirectoryPath(["/", "tmp", "test"].dropLast())!.string, "/tmp")
        XCTAssertEqual(FilePath(["/", "tmp", "flabbergasted", "other"].dropLast())!.string, "/tmp/flabbergasted")
    }

    func testStringLiteral() {
        let path1: GenericPath = "/tmp"
        XCTAssertEqual(path1.string, "/tmp")
    }

    func testArrayLiteral() {
        let path1: GenericPath = ["/", "tmp"]
        XCTAssertEqual(path1.string, "/tmp")
    }

    func testChRoot() {
        XCTAssertEqual(DirectoryPath.root.string, "/")

        if (geteuid() == 0) {
            DirectoryPath.root = DirectoryPath("/tmp")!
            XCTAssertEqual(DirectoryPath.root.string, "/tmp")
            DirectoryPath.root = DirectoryPath("/")!
        }
        XCTAssertEqual(DirectoryPath.root.string, "/")
    }

    func testChCWD() {
        DirectoryPath.cwd = DirectoryPath("/tmp")!
        XCTAssertEqual(DirectoryPath.cwd.string, "/tmp")
        DirectoryPath.cwd = DirectoryPath("/")!
        XCTAssertEqual(DirectoryPath.cwd.string, "/")
    }

    func testComponents() {
        XCTAssertEqual(GenericPath("/tmp").components, ["/", "tmp"])
        XCTAssertEqual(DirectoryPath("/tmp")!.components, ["/", "tmp"])
        XCTAssertEqual(FilePath("/tmp/flabbergasted")!.components, ["/", "tmp", "flabbergasted"])
    }

    func testLastComponent() {
        XCTAssertEqual(GenericPath("/tmp").lastComponent, "tmp")
        XCTAssertEqual(DirectoryPath("/tmp")!.lastComponent, "tmp")
        XCTAssertEqual(FilePath("/tmp/flabbergasted")!.lastComponent, "flabbergasted")
    }

    func testParent() {
        XCTAssertEqual(GenericPath("/tmp").parent.string, "/")
        XCTAssertEqual(DirectoryPath("/tmp")!.parent.string, "/")
        XCTAssertEqual(FilePath("/tmp/flabbergasted")!.parent.string, "/tmp")
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
        let relative2 = DirectoryPath("~/")!
        let relative3 = FilePath("~/flabbergasted")!

        XCTAssertFalse(relative1.isAbsolute)
        XCTAssertNotEqual(relative1, relative1.absolute)
        XCTAssertNotEqual(relative2, relative2.absolute)
        XCTAssertNotEqual(relative3, relative3.absolute)
        XCTAssertTrue(relative1.absolute?.isAbsolute ?? true)
    }

    func testExpand() {
        var relative = GenericPath("~/")

        XCTAssertFalse(relative.exists)
        XCTAssertNoThrow(try relative.expand())
        XCTAssertTrue(relative.exists)
    }

    func testRelative() {
        let relative1 = GenericPath("~/")
        let relative2 = DirectoryPath("./")!
        let relative3 = FilePath("../flabbergasted")!

        XCTAssertTrue(relative1.isRelative)
        XCTAssertTrue(relative2.isRelative)
        XCTAssertTrue(relative3.isRelative)
        XCTAssertEqual(relative1, relative1.absolute?.relative ?? relative1)
    }

    func testPathType() {
        guard let dir = DirectoryPath("/tmp") else {
            XCTFail("/tmp is not a directory")
            return
        }

        let pathType = PathType(mode: dir.permissions)
        XCTAssertNotNil(pathType)
        XCTAssertEqual(pathType!, .directory)
    }
}
