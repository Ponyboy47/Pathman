import Foundation
@testable import Pathman
import XCTest

class LinkTests: XCTestCase {
    func testRelativeSoftLink() {
        do {
            let link = try FilePath.temporary(prefix: "com.trailblazer.tests.softlink.")
            DirectoryPath.cwd = link.path.parent
            var _linked = FilePath("\(link.path.lastComponent!).link")!
            let target = FilePath("\(link.path.lastComponent!)")!
            let symlink = try target.link(at: "\(link.path.lastComponent!).link")
            XCTAssertTrue(symlink.isLink)
            XCTAssertTrue(symlink.exists)
            XCTAssertEqual(symlink.linkType, .soft)
            XCTAssertFalse(symlink.isDangling)
            XCTAssertEqual(symlink._path, _linked._path)
            var file = link.path
            try? file.delete()
            XCTAssertTrue(symlink.isDangling)
            try? _linked.delete()
        } catch {
            XCTFail("\(error)")
            return
        }
    }

    func testAbsoluteSoftLink() {
        do {
            let file = try FilePath.temporary(prefix: "com.trailblazer.tests.softlink.")

            var symlink = try file.path.link(at: FilePath("\(file.path.string).link")!)
            XCTAssertTrue(symlink.isLink)
            XCTAssertTrue(symlink.exists)
            XCTAssertEqual(symlink.linkType, .symbolic)
            XCTAssertFalse(symlink.isDangling)
            var _file = file.path
            try? _file.delete()
            XCTAssertTrue(symlink.isDangling)
            try? symlink.delete()
        } catch {
            XCTFail("\(error)")
            return
        }
    }

    func testRelativeHardLink() {
        do {
            let link = try FilePath.temporary(prefix: "com.trailblazer.tests.hardlink.")
            DirectoryPath.cwd = link.path.parent
            var _linked = FilePath("\(link.path.lastComponent!).link")!
            let target = FilePath("\(link.path.lastComponent!)")!
            var symlink = try target.link(at: _linked, type: .hard)
            XCTAssertTrue(symlink.isLink)
            XCTAssertTrue(symlink.exists)
            XCTAssertEqual(symlink.linkType, .hard)
            XCTAssertFalse(symlink.isDangling)
            XCTAssertEqual(symlink._path, _linked._path)
            var file = link.path
            try? file.delete()
            XCTAssertFalse(symlink.isDangling)
            try? _linked.delete()
            try? symlink.delete()
        } catch {
            XCTFail("\(error)")
            return
        }
    }

    func testAbsoluteHardLink() {
        do {
            let file = try FilePath.temporary(prefix: "com.trailblazer.tests.hardlink.")

            var symlink = try file.path.link(at: FilePath("\(file.path.string).link")!, type: .hard)
            XCTAssertTrue(symlink.isLink)
            XCTAssertTrue(symlink.exists)
            XCTAssertEqual(symlink.linkType, .hard)
            XCTAssertFalse(symlink.isDangling)
            var _file = file.path
            try? _file.delete()
            XCTAssertFalse(symlink.isDangling)
            try? symlink.delete()
        } catch {
            XCTFail("\(error)")
            return
        }
    }

    func testFromLinking() {
        let fromFile: FilePath
        let toFile: FilePath
        do {
            let openFile1 = try FilePath.temporary(prefix: "com.trailblazer.link.")
            var file1 = openFile1.path
            try? file1.delete()
            let openFile2 = try FilePath.temporary(prefix: "com.trailblazer.link.")
            var file2 = openFile2.path
            try? file2.delete()
            fromFile = openFile1.path
            toFile = openFile2.path
        } catch {
            XCTFail("Failed to create/delete a temporary file")
            return
        }

        do {
            var link = try toFile.link(from: fromFile)
            XCTAssertEqual(link.link, fromFile)
            try? link.delete()
            link = try toFile.link(from: fromFile.string)
            XCTAssertEqual(link.link, fromFile)
            try? link.delete()
        } catch {
            XCTFail("Failed to create link")
            return
        }
    }

    func testInits() {
        do {
            let file = try FilePath.temporary(prefix: "com.trailblazer.tests.softlink.")
            var symlink1 = try LinkedPath("\(file.path.string).link", linkedTo: file.path)
            try? symlink1.delete()
            var symlink2 = try LinkedPath(FilePath("\(file.path.string).link")!, linkedTo: file.path.string)
            try? symlink2.delete()
            var symlink3 = try LinkedPath<FilePath>("\(file.path.string).link", linkedTo: file.path.string)
            let symlink4 = LinkedPath<FilePath>("\(file.path.string).link")
            let symlink5 = LinkedPath<FilePath>(GenericPath("\(file.path.string).link").components)
            let symlink6 = LinkedPath(symlink5!)
            let symlink7 = LinkedPath<FilePath>(GenericPath("\(file.path.string).link"))

            XCTAssertEqual(symlink1, symlink2)
            XCTAssertEqual(symlink2, symlink3)
            XCTAssertEqual(symlink3, symlink4)
            XCTAssertEqual(symlink4, symlink5)
            XCTAssertEqual(symlink5, symlink6)
            XCTAssertEqual(symlink6, symlink7)

            XCTAssertTrue(symlink1.exists)
            XCTAssertTrue(symlink2.exists)
            XCTAssertTrue(symlink3.exists)
            XCTAssertTrue(symlink4!.exists)
            XCTAssertTrue(symlink5!.exists)
            XCTAssertTrue(symlink6.exists)
            XCTAssertTrue(symlink7!.exists)

            var _file = file.path
            try? _file.delete()
            try? symlink3.delete()
        } catch {
            XCTFail("\(error)")
        }
    }

    func testDirectoryEnumerable() {
        do {
            let link = try DirectoryPath.temporary(prefix: "com.trailblazer.tests.softlink.")
            DirectoryPath.cwd = link.path.parent
            var _linked = DirectoryPath("\(link.path.lastComponent!).link")!
            let target = DirectoryPath("\(link.path.lastComponent!)")!
            let symlink = try target.link(at: "\(link.path.lastComponent!).link")
            XCTAssertNoThrow(try symlink.children())
            var file = link.path
            try? file.delete()
            try? _linked.delete()
        } catch {
            XCTFail("\(error)")
            return
        }
    }

    func testOpenFile() {
        do {
            let link = try FilePath.temporary(prefix: "com.trailblazer.tests.softlink.")
            DirectoryPath.cwd = link.path.parent
            var _linked = FilePath("\(link.path.lastComponent!).link")!
            let target = FilePath("\(link.path.lastComponent!)")!
            let symlink = try target.link(at: "\(link.path.lastComponent!).link")
            XCTAssertNoThrow(try symlink.open(mode: .readPlus))
            var file = link.path
            try? file.delete()
            try? _linked.delete()
        } catch {
            XCTFail("\(error)")
            return
        }
    }

    func testOpenDirectory() {
        do {
            let link = try DirectoryPath.temporary(prefix: "com.trailblazer.tests.softlink.")
            DirectoryPath.cwd = link.path.parent
            var _linked = DirectoryPath("\(link.path.lastComponent!).link")!
            let target = DirectoryPath("\(link.path.lastComponent!)")!
            let symlink = try target.link(at: "\(link.path.lastComponent!).link")
            XCTAssertNoThrow(try symlink.open())
            var file = link.path
            try? file.delete()
            try? _linked.delete()
        } catch {
            XCTFail("\(error)")
            return
        }
    }

    func testOpenClosures() {
        do {
            let link = try FilePath.temporary(prefix: "com.trailblazer.tests.softlink.")
            DirectoryPath.cwd = link.path.parent
            var _linked = FilePath("\(link.path.lastComponent!).link")!
            let target = FilePath("\(link.path.lastComponent!)")!
            let symlink = try target.link(at: "\(link.path.lastComponent!).link")
            XCTAssertNoThrow(try symlink.open(mode: .readPlus) { _ in })
            var file = link.path
            try? file.delete()
            try? _linked.delete()
        } catch {
            XCTFail("\(error)")
            return
        }

        do {
            let link = try DirectoryPath.temporary(prefix: "com.trailblazer.tests.softlink.")
            DirectoryPath.cwd = link.path.parent
            var _linked = DirectoryPath("\(link.path.lastComponent!).link")!
            let target = DirectoryPath("\(link.path.lastComponent!)")!
            let symlink = try target.link(at: "\(link.path.lastComponent!).link")
            XCTAssertNoThrow(try symlink.open { _ in })
            var file = link.path
            try? file.delete()
            try? _linked.delete()
        } catch {
            XCTFail("\(error)")
            return
        }
    }
}
