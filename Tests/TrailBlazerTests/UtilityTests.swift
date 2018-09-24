import XCTest
@testable import TrailBlazer

class UtilityTests: XCTestCase {
    let byteAmount = 1
    let kbAmount = 1024
    let mbAmount = 1048576
    let gbAmount = 1073741824
    let tbAmount = 1099511627776
    let pbAmount = 1125899906842624

    func testKilobytes() {
        XCTAssertEqual(byteAmount.kilobytes, kbAmount)
        XCTAssertEqual(byteAmount.kb, kbAmount)
        XCTAssertEqual(Int64(byteAmount).kilobytes, kbAmount)
        XCTAssertEqual(Int64(byteAmount).kb, kbAmount)
        XCTAssertEqual(Double(byteAmount).kilobytes, kbAmount)
        XCTAssertEqual(Double(byteAmount).kb, kbAmount)
        XCTAssertEqual(Float(byteAmount).kilobytes, kbAmount)
        XCTAssertEqual(Float(byteAmount).kb, kbAmount)
    }

    func testMegabytes() {
        XCTAssertEqual(byteAmount.megabytes, mbAmount)
        XCTAssertEqual(byteAmount.mb, mbAmount)
        XCTAssertEqual(Int64(byteAmount).megabytes, mbAmount)
        XCTAssertEqual(Int64(byteAmount).mb, mbAmount)
        XCTAssertEqual(Double(byteAmount).megabytes, mbAmount)
        XCTAssertEqual(Double(byteAmount).mb, mbAmount)
        XCTAssertEqual(Float(byteAmount).megabytes, mbAmount)
        XCTAssertEqual(Float(byteAmount).mb, mbAmount)
    }

    func testGigabytes() {
        XCTAssertEqual(byteAmount.gigabytes, gbAmount)
        XCTAssertEqual(byteAmount.gb, gbAmount)
        XCTAssertEqual(Int64(byteAmount).gigabytes, gbAmount)
        XCTAssertEqual(Int64(byteAmount).gb, gbAmount)
        XCTAssertEqual(Double(byteAmount).gigabytes, gbAmount)
        XCTAssertEqual(Double(byteAmount).gb, gbAmount)
        XCTAssertEqual(Float(byteAmount).gigabytes, gbAmount)
        XCTAssertEqual(Float(byteAmount).gb, gbAmount)
    }

    func testTerabytes() {
        XCTAssertEqual(byteAmount.terabytes, tbAmount)
        XCTAssertEqual(byteAmount.tb, tbAmount)
        XCTAssertEqual(Int64(byteAmount).terabytes, tbAmount)
        XCTAssertEqual(Int64(byteAmount).tb, tbAmount)
        XCTAssertEqual(Double(byteAmount).terabytes, tbAmount)
        XCTAssertEqual(Double(byteAmount).tb, tbAmount)
        XCTAssertEqual(Float(byteAmount).terabytes, tbAmount)
        XCTAssertEqual(Float(byteAmount).tb, tbAmount)
    }

    func testPetabytes() {
        XCTAssertEqual(byteAmount.petabytes, pbAmount)
        XCTAssertEqual(byteAmount.pb, pbAmount)
        XCTAssertEqual(Int64(byteAmount).petabytes, pbAmount)
        XCTAssertEqual(Int64(byteAmount).pb, pbAmount)
        XCTAssertEqual(Double(byteAmount).petabytes, pbAmount)
        XCTAssertEqual(Double(byteAmount).pb, pbAmount)
        XCTAssertEqual(Float(byteAmount).petabytes, pbAmount)
        XCTAssertEqual(Float(byteAmount).pb, pbAmount)
    }

    #if os(Linux)
    static let allTests = [
        ("testKilobytes", testKilobytes),
        ("testMegabytes", testMegabytes),
        ("testGigabytes", testGigabytes),
        ("testTerabytes", testTerabytes),
        ("testPetabytes", testPetabytes),
    ]
    #endif
}

