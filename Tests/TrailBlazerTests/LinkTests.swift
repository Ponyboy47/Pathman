import Foundation
import XCTest
@testable import TrailBlazer

class LinkTests: XCTestCase {
    func testRelativeSoftLink() {
        do {
            let link = try FilePath.temporary(prefix: "com.trailblazer.tests.softlink.")
            DirectoryPath.cwd = link.path.parent
            let _linked = FilePath("\(link.path.lastComponent!).link")!
            let target = FilePath("\(link.path.lastComponent!)")!
            let symlink = try target.link(at: "\(link.path.lastComponent!).link")
            XCTAssertTrue(symlink.isLink)
            XCTAssertTrue(symlink.exists)
            XCTAssertEqual(symlink.linkType, .soft)
            XCTAssertFalse(symlink.isDangling)
            try? link.delete()
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

            let symlink = try file.path.link(at: FilePath("\(file.path.string).link")!)
            XCTAssertTrue(symlink.isLink)
            XCTAssertTrue(symlink.exists)
            XCTAssertEqual(symlink.linkType, .symbolic)
            XCTAssertFalse(symlink.isDangling)
            try? file.delete()
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
            let _linked = FilePath("\(link.path.lastComponent!).link")!
            let target = FilePath("\(link.path.lastComponent!)")!
            let symlink = try target.link(at: _linked, type: .hard)
            XCTAssertTrue(symlink.isLink)
            XCTAssertTrue(symlink.exists)
            XCTAssertEqual(symlink.linkType, .hard)
            XCTAssertFalse(symlink.isDangling)
            try? link.delete()
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

            let symlink = try file.path.link(at: FilePath("\(file.path.string).link")!, type: .hard)
            XCTAssertTrue(symlink.isLink)
            XCTAssertTrue(symlink.exists)
            XCTAssertEqual(symlink.linkType, .hard)
            XCTAssertFalse(symlink.isDangling)
            try? file.delete()
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
            try openFile1.delete()
            let openFile2 = try FilePath.temporary(prefix: "com.trailblazer.link.")
            try openFile2.delete()
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
}
