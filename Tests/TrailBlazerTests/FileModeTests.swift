import XCTest
@testable import TrailBlazer

class FileModeTests: XCTestCase {
    func testOwnerRead() {
        let mode: FileMode = .owner(.read)
        XCTAssertEqual(mode.rawValue, 0o400)
    }

    func testOwnerWrite() {
        let mode: FileMode = .owner(.write)
        XCTAssertEqual(mode.rawValue, 0o200)
    }

    func testOwnerExecute() {
        let mode: FileMode = .owner(.execute)
        XCTAssertEqual(mode.rawValue, 0o100)
    }

    func testOwnerReadWrite() {
        let mode: FileMode = .owner(.read, .write)
        XCTAssertEqual(mode.rawValue, 0o600)
    }

    func testOwnerReadExecute() {
        let mode: FileMode = .owner(.read, .execute)
        XCTAssertEqual(mode.rawValue, 0o500)
    }

    func testOwnerWriteExecute() {
        let mode: FileMode = .owner(.write, .execute)
        XCTAssertEqual(mode.rawValue, 0o300)
    }

    func testOwnerReadWriteExecute() {
        let mode: FileMode = .owner(.read, .write, .execute)
        XCTAssertEqual(mode.rawValue, 0o700)
    }

    func testGroupRead() {
        let mode: FileMode = .group(.read)
        XCTAssertEqual(mode.rawValue, 0o40)
    }

    func testGroupWrite() {
        let mode: FileMode = .group(.write)
        XCTAssertEqual(mode.rawValue, 0o20)
    }

    func testGroupExecute() {
        let mode: FileMode = .group(.execute)
        XCTAssertEqual(mode.rawValue, 0o10)
    }

    func testGroupReadWrite() {
        let mode: FileMode = .group(.read, .write)
        XCTAssertEqual(mode.rawValue, 0o60)
    }

    func testGroupReadExecute() {
        let mode: FileMode = .group(.read, .execute)
        XCTAssertEqual(mode.rawValue, 0o50)
    }

    func testGroupWriteExecute() {
        let mode: FileMode = .group(.write, .execute)
        XCTAssertEqual(mode.rawValue, 0o30)
    }

    func testGroupReadWriteExecute() {
        let mode: FileMode = .group(.read, .write, .execute)
        XCTAssertEqual(mode.rawValue, 0o70)
    }

    func testOthersRead() {
        let mode: FileMode = .others(.read)
        XCTAssertEqual(mode.rawValue, 0o4)
    }

    func testOthersWrite() {
        let mode: FileMode = .others(.write)
        XCTAssertEqual(mode.rawValue, 0o2)
    }

    func testOthersExecute() {
        let mode: FileMode = .others(.execute)
        XCTAssertEqual(mode.rawValue, 0o1)
    }

    func testOthersReadWrite() {
        let mode: FileMode = .others(.read, .write)
        XCTAssertEqual(mode.rawValue, 0o6)
    }

    func testOthersReadExecute() {
        let mode: FileMode = .others(.read, .execute)
        XCTAssertEqual(mode.rawValue, 0o5)
    }

    func testOthersWriteExecute() {
        let mode: FileMode = .others(.write, .execute)
        XCTAssertEqual(mode.rawValue, 0o3)
    }

    func testOthersReadWriteExecute() {
        let mode: FileMode = .others(.read, .write, .execute)
        XCTAssertEqual(mode.rawValue, 0o7)
    }

    func testOwnerGroupRead() {
        let mode: FileMode = .ownerGroup(.read)
        XCTAssertEqual(mode.rawValue, 0o440)
    }

    func testOwnerGroupWrite() {
        let mode: FileMode = .ownerGroup(.write)
        XCTAssertEqual(mode.rawValue, 0o220)
    }

    func testOwnerGroupExecute() {
        let mode: FileMode = .ownerGroup(.execute)
        XCTAssertEqual(mode.rawValue, 0o110)
    }

    func testOwnerGroupReadWrite() {
        let mode: FileMode = .ownerGroup(.read, .write)
        XCTAssertEqual(mode.rawValue, 0o660)
    }

    func testOwnerGroupReadExecute() {
        let mode: FileMode = .ownerGroup(.read, .execute)
        XCTAssertEqual(mode.rawValue, 0o550)
    }

    func testOwnerGroupWriteExecute() {
        let mode: FileMode = .ownerGroup(.write, .execute)
        XCTAssertEqual(mode.rawValue, 0o330)
    }

    func testOwnerGroupReadWriteExecute() {
        let mode: FileMode = .ownerGroup(.read, .write, .execute)
        XCTAssertEqual(mode.rawValue, 0o770)
    }

    func testOwnerOthersRead() {
        let mode: FileMode = .ownerOthers(.read)
        XCTAssertEqual(mode.rawValue, 0o404)
    }

    func testOwnerOthersWrite() {
        let mode: FileMode = .ownerOthers(.write)
        XCTAssertEqual(mode.rawValue, 0o202)
    }

    func testOwnerOthersExecute() {
        let mode: FileMode = .ownerOthers(.execute)
        XCTAssertEqual(mode.rawValue, 0o101)
    }

    func testOwnerOthersReadWrite() {
        let mode: FileMode = .ownerOthers(.read, .write)
        XCTAssertEqual(mode.rawValue, 0o606)
    }

    func testOwnerOthersReadExecute() {
        let mode: FileMode = .ownerOthers(.read, .execute)
        XCTAssertEqual(mode.rawValue, 0o505)
    }

    func testOwnerOthersWriteExecute() {
        let mode: FileMode = .ownerOthers(.write, .execute)
        XCTAssertEqual(mode.rawValue, 0o303)
    }

    func testOwnerOthersReadWriteExecute() {
        let mode: FileMode = .ownerOthers(.read, .write, .execute)
        XCTAssertEqual(mode.rawValue, 0o707)
    }

    func testGroupOthersRead() {
        let mode: FileMode = .groupOthers(.read)
        XCTAssertEqual(mode.rawValue, 0o44)
    }

    func testGroupOthersWrite() {
        let mode: FileMode = .groupOthers(.write)
        XCTAssertEqual(mode.rawValue, 0o22)
    }

    func testGroupOthersExecute() {
        let mode: FileMode = .groupOthers(.execute)
        XCTAssertEqual(mode.rawValue, 0o11)
    }

    func testGroupOthersReadWrite() {
        let mode: FileMode = .groupOthers(.read, .write)
        XCTAssertEqual(mode.rawValue, 0o66)
    }

    func testGroupOthersReadExecute() {
        let mode: FileMode = .groupOthers(.read, .execute)
        XCTAssertEqual(mode.rawValue, 0o55)
    }

    func testGroupOthersWriteExecute() {
        let mode: FileMode = .groupOthers(.write, .execute)
        XCTAssertEqual(mode.rawValue, 0o33)
    }

    func testGroupOthersReadWriteExecute() {
        let mode: FileMode = .groupOthers(.read, .write, .execute)
        XCTAssertEqual(mode.rawValue, 0o77)
    }

    func testOwnerGroupOthersRead() {
        let mode: FileMode = .ownerGroupOthers(.read)
        XCTAssertEqual(mode.rawValue, 0o444)
    }

    func testOwnerGroupOthersWrite() {
        let mode: FileMode = .ownerGroupOthers(.write)
        XCTAssertEqual(mode.rawValue, 0o222)
    }

    func testOwnerGroupOthersExecute() {
        let mode: FileMode = .ownerGroupOthers(.execute)
        XCTAssertEqual(mode.rawValue, 0o111)
    }

    func testOwnerGroupOthersReadWrite() {
        let mode: FileMode = .ownerGroupOthers(.read, .write)
        XCTAssertEqual(mode.rawValue, 0o666)
    }

    func testOwnerGroupOthersReadExecute() {
        let mode: FileMode = .ownerGroupOthers(.read, .execute)
        XCTAssertEqual(mode.rawValue, 0o555)
    }

    func testOwnerGroupOthersWriteExecute() {
        let mode: FileMode = .ownerGroupOthers(.write, .execute)
        XCTAssertEqual(mode.rawValue, 0o333)
    }

    func testOwnerGroupOthersReadWriteExecute() {
        let mode: FileMode = .ownerGroupOthers(.read, .write, .execute)
        XCTAssertEqual(mode.rawValue, 0o777)
    }

    static var allTests = [
        ("testOwnerRead", testOwnerRead),
        ("testOwnerWrite", testOwnerWrite),
        ("testOwnerExecute", testOwnerExecute),
        ("testOwnerReadWrite", testOwnerReadWrite),
        ("testOwnerReadExecute", testOwnerReadExecute),
        ("testOwnerWriteExecute", testOwnerWriteExecute),
        ("testOwnerReadWriteExecute", testOwnerReadWriteExecute),
        ("testGroupRead", testGroupRead),
        ("testGroupWrite", testGroupWrite),
        ("testGroupExecute", testGroupExecute),
        ("testGroupReadWrite", testGroupReadWrite),
        ("testGroupReadExecute", testGroupReadExecute),
        ("testGroupWriteExecute", testGroupWriteExecute),
        ("testGroupReadWriteExecute", testGroupReadWriteExecute),
        ("testOthersRead", testOthersRead),
        ("testOthersWrite", testOthersWrite),
        ("testOthersExecute", testOthersExecute),
        ("testOthersReadWrite", testOthersReadWrite),
        ("testOthersReadExecute", testOthersReadExecute),
        ("testOthersWriteExecute", testOthersWriteExecute),
        ("testOthersReadWriteExecute", testOthersReadWriteExecute),
        ("testOwnerGroupRead", testOwnerGroupRead),
        ("testOwnerGroupWrite", testOwnerGroupWrite),
        ("testOwnerGroupExecute", testOwnerGroupExecute),
        ("testOwnerGroupReadWrite", testOwnerGroupReadWrite),
        ("testOwnerGroupReadExecute", testOwnerGroupReadExecute),
        ("testOwnerGroupWriteExecute", testOwnerGroupWriteExecute),
        ("testOwnerGroupReadWriteExecute", testOwnerGroupReadWriteExecute),
        ("testOwnerOthersRead", testOwnerOthersRead),
        ("testOwnerOthersWrite", testOwnerOthersWrite),
        ("testOwnerOthersExecute", testOwnerOthersExecute),
        ("testOwnerOthersReadWrite", testOwnerOthersReadWrite),
        ("testOwnerOthersReadExecute", testOwnerOthersReadExecute),
        ("testOwnerOthersWriteExecute", testOwnerOthersWriteExecute),
        ("testOwnerOthersReadWriteExecute", testOwnerOthersReadWriteExecute),
        ("testGroupOthersRead", testGroupOthersRead),
        ("testGroupOthersWrite", testGroupOthersWrite),
        ("testGroupOthersExecute", testGroupOthersExecute),
        ("testGroupOthersReadWrite", testGroupOthersReadWrite),
        ("testGroupOthersReadExecute", testGroupOthersReadExecute),
        ("testGroupOthersWriteExecute", testGroupOthersWriteExecute),
        ("testGroupOthersReadWriteExecute", testGroupOthersReadWriteExecute),
        ("testOwnerGroupOthersRead", testOwnerGroupOthersRead),
        ("testOwnerGroupOthersWrite", testOwnerGroupOthersWrite),
        ("testOwnerGroupOthersExecute", testOwnerGroupOthersExecute),
        ("testOwnerGroupOthersReadWrite", testOwnerGroupOthersReadWrite),
        ("testOwnerGroupOthersReadExecute", testOwnerGroupOthersReadExecute),
        ("testOwnerGroupOthersWriteExecute", testOwnerGroupOthersWriteExecute),
        ("testOwnerGroupOthersReadWriteExecute", testOwnerGroupOthersReadWriteExecute),
    ]
}
