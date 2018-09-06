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
            XCTAssertEqual(symlink.linkType!, .soft)
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
            XCTAssertEqual(symlink.linkType!, .symbolic)
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
            XCTAssertEqual(symlink.linkType!, .hard)
            XCTAssertFalse(symlink.isDangling)
            try? link.delete()
            XCTAssertFalse(symlink.isDangling)
            try? _linked.delete()
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
            XCTAssertEqual(symlink.linkType!, .hard)
            XCTAssertFalse(symlink.isDangling)
            try? file.delete()
            XCTAssertFalse(symlink.isDangling)
            try? symlink.delete()
        } catch {
            XCTFail("\(error)")
            return
        }
    }

    static var allTests = [
        ("testAbsoluteSoftLink", testAbsoluteSoftLink),
        ("testRelativeSoftLink", testRelativeSoftLink),
        ("testAbsoluteHardLink", testAbsoluteHardLink),
        ("testRelativeHardLink", testRelativeHardLink),
    ]
}
