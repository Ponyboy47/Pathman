import XCTest
@testable import TrailBlazer

class FileBitsTests: XCTestCase {
    let all: FileBits = .all
    let uid: FileBits = .uid
    let gid: FileBits = .gid
    let sticky: FileBits = .sticky
    let none: FileBits = .none
    let uidGid = FileBits(.uid, .gid)
    let uidSticky: FileBits = 0o5
    let gidSticky = FileBits(rawValue: 0o3)

    func testHasNone() {
        XCTAssertFalse(all.hasNone)
        XCTAssertFalse(uid.hasNone)
        XCTAssertFalse(gid.hasNone)
        XCTAssertFalse(sticky.hasNone)
        XCTAssertFalse(uidGid.hasNone)
        XCTAssertFalse(uidSticky.hasNone)
        XCTAssertFalse(gidSticky.hasNone)
        XCTAssertTrue(none.hasNone)
    }

    func testEquality() {
        XCTAssertEqual(all, FileBits(uid: true, gid: true, sticky: true))
        XCTAssertEqual(uid, FileBits(uid: true, gid: false, sticky: false))
        XCTAssertEqual(gid, FileBits(uid: false, gid: true, sticky: false))
        XCTAssertEqual(sticky, FileBits(uid: false, gid: false, sticky: true))
        XCTAssertEqual(none, FileBits(uid: false, gid: false, sticky: false))
        XCTAssertEqual(uidGid, FileBits(uid: true, gid: true, sticky: false))
        XCTAssertEqual(uidSticky, FileBits(uid: true, gid: false, sticky: true))
        XCTAssertEqual(gidSticky, FileBits(uid: false, gid: true, sticky: true))

        XCTAssertNotEqual(all, uid)
        XCTAssertNotEqual(all, gid)
        XCTAssertNotEqual(all, sticky)
        XCTAssertNotEqual(all, uidGid)
        XCTAssertNotEqual(all, uidSticky)
        XCTAssertNotEqual(all, gidSticky)
        XCTAssertNotEqual(all, none)
    }

    func testContains() {
        XCTAssertTrue(all.contains(uid))
        XCTAssertTrue(all.contains(gid))
        XCTAssertTrue(all.contains(sticky))
        XCTAssertTrue(all.contains(uidGid))
        XCTAssertTrue(all.contains(uidSticky))
        XCTAssertTrue(all.contains(gidSticky))
        XCTAssertTrue(all.contains(none))
    }

    func testCustomStringConvertible() {
        XCTAssertEqual(all.description, "FileBits(uid, gid, sticky)")
        XCTAssertEqual(uid.description, "FileBits(uid)")
        XCTAssertEqual(gid.description, "FileBits(gid)")
        XCTAssertEqual(sticky.description, "FileBits(sticky)")
        XCTAssertEqual(uidGid.description, "FileBits(uid, gid)")
        XCTAssertEqual(uidSticky.description, "FileBits(uid, sticky)")
        XCTAssertEqual(gidSticky.description, "FileBits(gid, sticky)")
        XCTAssertEqual(none.description, "FileBits(none)")
    }

    func testOrOperator() {
        let all: FileBits = .all
        let uid: FileBits = .uid
        let gid: FileBits = .gid
        let sticky: FileBits = .sticky
        var empty: FileBits = .none

        XCTAssertEqual(uid | gid | sticky, all)
        XCTAssertEqual(uid | gid.rawValue | sticky.rawValue, all)

        XCTAssertNotEqual(empty, all)
        empty |= uid
        XCTAssertEqual(empty, uid)
        empty |= (gid | sticky).rawValue
        XCTAssertEqual(empty, all)
    }

    func testAndOperator() {
        var all: FileBits = .all
        let uid: FileBits = .uid
        let gid: FileBits = .gid
        let sticky: FileBits = .sticky
        let empty: FileBits = .none

        XCTAssertEqual(all & uid, uid)
        XCTAssertEqual(all & gid.rawValue, gid)

        XCTAssertNotEqual(empty, all)
        all &= sticky
        XCTAssertEqual(all, sticky)
        all &= (gid | uid).rawValue
        XCTAssertEqual(empty, all)
    }
}


