import XCTest
#if os(Linux)
import Glibc
#else
import Darwin
#endif
@testable import PathMan

class PathTests: XCTestCase {
    func testStringInit() {
        XCTAssertEqual(GenericPath("/tmp/").string, "/tmp")
        let dir = DirectoryPath("/tmp")
        XCTAssertNotNil(dir)
        XCTAssertEqual(dir!.string, "/tmp")
        let file = FilePath("/tmp/flabbergasted/")
        XCTAssertNotNil(file)
        XCTAssertEqual(file!.string, "/tmp/flabbergasted")
        let socket = SocketPath("/tmp/flabbergasted/")
        XCTAssertNotNil(socket)
        XCTAssertEqual(socket!.string, "/tmp/flabbergasted")
    }

    func testPathInit() {
        XCTAssertEqual(GenericPath(GenericPath("/tmp")).string, "/tmp")
        XCTAssertEqual(GenericPath(DirectoryPath("/tmp")!).string, "/tmp")
        XCTAssertEqual(GenericPath(FilePath("/tmp/flabbergasted")!).string, "/tmp/flabbergasted")

        XCTAssertEqual(DirectoryPath(GenericPath("/tmp"))!.string, "/tmp")
        XCTAssertEqual(DirectoryPath(DirectoryPath("/tmp")!).string, "/tmp")

        XCTAssertEqual(FilePath(GenericPath("/tmp/flabbergasted"))!.string, "/tmp/flabbergasted")
        XCTAssertEqual(FilePath(FilePath("/tmp/flabbergasted")!).string, "/tmp/flabbergasted")

        XCTAssertEqual(SocketPath(GenericPath("/tmp/flabbergasted"))!.string, "/tmp/flabbergasted")
        XCTAssertEqual(SocketPath(SocketPath("/tmp/flabbergasted")!).string, "/tmp/flabbergasted")
    }

    func testVariadicInit() {
        XCTAssertEqual(GenericPath("/", "tmp").string, "/tmp")
        XCTAssertEqual(DirectoryPath("/", "tmp")!.string, "/tmp")
        XCTAssertEqual(FilePath("/", "tmp", "flabbergasted")!.string, "/tmp/flabbergasted")
        XCTAssertEqual(SocketPath("/", "tmp", "flabbergasted")!.string, "/tmp/flabbergasted")
    }

    func testArrayInit() {
        XCTAssertEqual(GenericPath(["/", "tmp"]).string, "/tmp")
        XCTAssertEqual(DirectoryPath(["/", "tmp"])!.string, "/tmp")
        XCTAssertEqual(FilePath(["/", "tmp", "flabbergasted"])!.string, "/tmp/flabbergasted")
        XCTAssertEqual(SocketPath(["/", "tmp", "flabbergasted"])!.string, "/tmp/flabbergasted")
        XCTAssertNil(FilePath(["/", "tmp"]))
    }

    func testArraySliceInit() {
        XCTAssertEqual(GenericPath(["/", "tmp", "test"].dropLast()).string, "/tmp")
        XCTAssertEqual(DirectoryPath(["/", "tmp", "test"].dropLast())!.string, "/tmp")
        XCTAssertEqual(FilePath(["/", "tmp", "flabbergasted", "other"].dropLast())!.string, "/tmp/flabbergasted")
        XCTAssertEqual(SocketPath(["/", "tmp", "flabbergasted", "other"].dropLast())!.string, "/tmp/flabbergasted")
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

    func testChCWD() {
        let directory = DirectoryPath()!
        DirectoryPath.cwd = DirectoryPath("/tmp")!
        directory.cwd = DirectoryPath("/tmp")!
        #if os(macOS)
        XCTAssertEqual(DirectoryPath.cwd.string, "/private/tmp")
        XCTAssertEqual(directory.cwd.string, "/private/tmp")
        #else
        XCTAssertEqual(DirectoryPath.cwd.string, "/tmp")
        XCTAssertEqual(directory.cwd.string, "/tmp")
        #endif
        DirectoryPath.cwd = DirectoryPath("/")!
        directory.cwd = DirectoryPath("/")!
        XCTAssertEqual(DirectoryPath.cwd.string, "/")
        XCTAssertEqual(directory.cwd.string, "/")

        do {
            try changeCWD(to: DirectoryPath("/tmp")!) {
                #if os(macOS)
                XCTAssertEqual(directory.cwd, DirectoryPath("/private/tmp")!)
                #else
                XCTAssertEqual(directory.cwd, DirectoryPath("/tmp")!)
                #endif
            }
            XCTAssertEqual(directory.cwd.string, "/")
        } catch {
            XCTFail("Failed to change current directory")
        }
    }

    func testComponents() {
        XCTAssertEqual(GenericPath("/tmp").components, ["/", "tmp"])
        XCTAssertEqual(DirectoryPath("/tmp")!.components, ["/", "tmp"])
        XCTAssertEqual(FilePath("/tmp/flabbergasted")!.components, ["/", "tmp", "flabbergasted"])
        XCTAssertEqual(SocketPath("/tmp/flabbergasted")!.components, ["/", "tmp", "flabbergasted"])
    }

    func testLastComponent() {
        XCTAssertEqual(GenericPath("/tmp").lastComponent, "tmp")
        XCTAssertEqual(DirectoryPath("/tmp")!.lastComponent, "tmp")
        XCTAssertEqual(FilePath("/tmp/flabbergasted.test")!.lastComponent, "flabbergasted.test")
        XCTAssertEqual(SocketPath("/tmp/flabbergasted.test")!.lastComponent, "flabbergasted.test")
    }

    func testLastComponentWithoutExtension() {
        XCTAssertEqual(FilePath("/tmp/flabbergasted.test")!.lastComponentWithoutExtension, "flabbergasted")
        XCTAssertEqual(SocketPath("/tmp/flabbergasted.sock")!.lastComponentWithoutExtension, "flabbergasted")
    }

    func testParent() {
        let dir = DirectoryPath("/tmp")!
        XCTAssertEqual(GenericPath("/tmp").parent.string, "/")
        XCTAssertEqual(dir.parent.string, "/")
        XCTAssertEqual(dir.parent.parent.string, "/")
        XCTAssertEqual(FilePath("flabbergasted/whatever")!.parent.parent.string, FilePath.cwd.string)
        XCTAssertEqual(SocketPath("flabbergasted/whatever")!.parent.parent.string, SocketPath.cwd.string)
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

    func testAncestors() {
        let short = GenericPath("/tmp/test")
        let long = GenericPath("/tmp/test/dir/with/a/file.txt")

        XCTAssertEqual(short.commonAncestor(with: long), DirectoryPath(short)!)
        XCTAssertEqual(long.commonAncestor(with: short), DirectoryPath(short)!)
    }

    func testExists() {
        XCTAssertTrue(DirectoryPath("/tmp")!.exists)
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

        XCTAssertEqual(dir.type, .directory)
    }

    func testPathTypeInits() {
        let socket: PathType = "socket"
        let file: PathType = "file"
        let link: PathType = "link"
        let block: PathType = "block"
        let dir: PathType = "directory"
        let char: PathType = "character"
        let fifo: PathType = "fifo"
        let unknown: PathType = "bvhaerogae"

        XCTAssertEqual(PathType(stringValue: "sock"), socket)
        XCTAssertEqual(PathType(stringValue: "regular"), file)
        XCTAssertEqual(PathType(stringValue: "symlink"), link)
        XCTAssertEqual(PathType(stringValue: "blk"), block)
        XCTAssertEqual(PathType(stringValue: "dir"), dir)
        XCTAssertEqual(PathType(stringValue: "char"), char)
        XCTAssertEqual(PathType(stringValue: "fifo"), fifo)
        XCTAssertEqual(unknown.stringValue, "unknown")
        XCTAssertEqual(PathType(stringValue: "nbiaoetra"), .unknown)
        XCTAssertEqual(PathType(intValue: -1), .unknown)
        XCTAssertEqual(PathType(intValue: Int(OSUInt.max)).rawValue, S_IFMT & OSUInt.max)
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

    func testCodable() {
        let path = FilePath("/path/to/test/location")!

        do {
            let encoded = try JSONEncoder().encode(path)
            let decoded = try JSONDecoder().decode(FilePath.self, from: encoded)
            XCTAssertEqual(path, decoded)
        } catch {
            XCTFail("Failed to encode/decode path \(error)")
        }
    }

    func testIses() {
        let path = DirectoryPath("/tmp")!
        XCTAssertTrue(path.isReadable)
        XCTAssertTrue(path.isWritable)
        XCTAssertTrue(path.isExecutable)
    }

    func testChangeSeparator() {
        let path = DirectoryPath("/path/to/file")!
        let components = path.components
        path.separator = "$"
        XCTAssertEqual(path.separator, "$")
        XCTAssertEqual(DirectoryPath.separator, "$")
        let newPath = DirectoryPath(["$"] + components.dropFirst())!
        XCTAssertEqual(newPath.string, "$path$to$file")
        XCTAssertEqual(newPath.components.dropFirst(), components.dropFirst())
        path.separator = "/"
    }

    func testAutoOpenFunctions() {
        let path = try! FilePath.temporary(prefix: "com.trailblazer.test").path

        XCTAssertNoThrow(try path.write("Hello world"))
        do {
            let contents: String! = try path.read()
            XCTAssertEqual(contents, "Hello world")
        } catch {
            XCTFail("Failed to open and read path")
            return
        }

        XCTAssertNoThrow(try path.write("\nMy name is Jacob", at: Offset(.end, 0)))

        do {
            let contents: String! = try path.read(from: Offset(.beginning, 12))
            XCTAssertEqual(contents, "My name is Jacob")
        } catch {
            XCTFail("Failed to open and read path from offset")
        }
    }
}
