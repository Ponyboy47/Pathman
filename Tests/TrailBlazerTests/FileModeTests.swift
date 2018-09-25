import XCTest
@testable import TrailBlazer

class FileModeTests: XCTestCase {
    func testOwnerRead() {
        let mode: FileMode = .owner(.read)
        XCTAssertEqual(mode.rawValue, 0o400)
        XCTAssertEqual(FileMode("-r--------"), mode)
        XCTAssertEqual("-r--------", mode)
    }

    func testOwnerWrite() {
        let mode: FileMode = .owner(.write)
        XCTAssertEqual(mode.rawValue, 0o200)
        XCTAssertEqual(FileMode("--w-------"), mode)
        XCTAssertEqual("--w-------", mode)
    }

    func testOwnerExecute() {
        let mode: FileMode = .owner(.execute)
        XCTAssertEqual(mode.rawValue, 0o100)
        XCTAssertEqual(FileMode("---x------"), mode)
        XCTAssertEqual("---x------", mode)
    }

    func testOwnerReadWrite() {
        var mode: FileMode = .owner([.read, .write])
        XCTAssertEqual(mode.rawValue, 0o600)
        mode = .owner(.readWrite)
        XCTAssertEqual(mode.rawValue, 0o600)
        XCTAssertEqual(FileMode("-rw-------"), mode)
        XCTAssertEqual("-rw-------", mode)
    }

    func testOwnerReadExecute() {
        var mode: FileMode = .owner([.read, .execute])
        XCTAssertEqual(mode.rawValue, 0o500)
        mode = .owner(.readExecute)
        XCTAssertEqual(mode.rawValue, 0o500)
        XCTAssertEqual(FileMode("-r-x------"), mode)
        XCTAssertEqual("-r-x------", mode)
    }

    func testOwnerWriteExecute() {
        var mode: FileMode = .owner([.write, .execute])
        XCTAssertEqual(mode.rawValue, 0o300)
        mode = .owner(.writeExecute)
        XCTAssertEqual(mode.rawValue, 0o300)
        XCTAssertEqual(FileMode("--wx------"), mode)
        XCTAssertEqual("--wx------", mode)
    }

    func testOwnerReadWriteExecute() {
        var mode: FileMode = .owner([.read, .write, .execute])
        XCTAssertEqual(mode.rawValue, 0o700)
        mode = .owner(.readWriteExecute)
        XCTAssertEqual(mode.rawValue, 0o700)
        XCTAssertEqual(FileMode("-rwx------"), mode)
        XCTAssertEqual("-rwx------", mode)
    }

    func testGroupRead() {
        let mode: FileMode = .group(.read)
        XCTAssertEqual(mode.rawValue, 0o40)
        XCTAssertEqual(FileMode("----r-----"), mode)
        XCTAssertEqual("----r-----", mode)
    }

    func testGroupWrite() {
        let mode: FileMode = .group(.write)
        XCTAssertEqual(mode.rawValue, 0o20)
        XCTAssertEqual(FileMode("-----w----"), mode)
        XCTAssertEqual("-----w----", mode)
    }

    func testGroupExecute() {
        let mode: FileMode = .group(.execute)
        XCTAssertEqual(mode.rawValue, 0o10)
        XCTAssertEqual(FileMode("------x---"), mode)
        XCTAssertEqual("------x---", mode)
    }

    func testGroupReadWrite() {
        var mode: FileMode = .group([.read, .write])
        XCTAssertEqual(mode.rawValue, 0o60)
        mode = .group(.readWrite)
        XCTAssertEqual(mode.rawValue, 0o60)
        XCTAssertEqual(FileMode("----rw----"), mode)
        XCTAssertEqual("----rw----", mode)
    }

    func testGroupReadExecute() {
        var mode: FileMode = .group([.read, .execute])
        XCTAssertEqual(mode.rawValue, 0o50)
        mode = .group(.readExecute)
        XCTAssertEqual(mode.rawValue, 0o50)
        XCTAssertEqual(FileMode("----r-x---"), mode)
        XCTAssertEqual("----r-x---", mode)
    }

    func testGroupWriteExecute() {
        var mode: FileMode = .group([.write, .execute])
        XCTAssertEqual(mode.rawValue, 0o30)
        mode = .group(.writeExecute)
        XCTAssertEqual(mode.rawValue, 0o30)
        XCTAssertEqual(FileMode("-----wx---"), mode)
        XCTAssertEqual("-----wx---", mode)
    }

    func testGroupReadWriteExecute() {
        var mode: FileMode = .group([.read, .write, .execute])
        XCTAssertEqual(mode.rawValue, 0o70)
        mode = .group(.readWriteExecute)
        XCTAssertEqual(mode.rawValue, 0o70)
        XCTAssertEqual(FileMode("----rwx---"), mode)
        XCTAssertEqual("----rwx---", mode)
    }

    func testOthersRead() {
        let mode: FileMode = .others(.read)
        XCTAssertEqual(mode.rawValue, 0o4)
        XCTAssertEqual(FileMode("-------r--"), mode)
        XCTAssertEqual("-------r--", mode)
    }

    func testOthersWrite() {
        let mode: FileMode = .others(.write)
        XCTAssertEqual(mode.rawValue, 0o2)
        XCTAssertEqual(FileMode("--------w-"), mode)
        XCTAssertEqual("--------w-", mode)
    }

    func testOthersExecute() {
        let mode: FileMode = .others(.execute)
        XCTAssertEqual(mode.rawValue, 0o1)
        XCTAssertEqual(FileMode("---------x"), mode)
        XCTAssertEqual("---------x", mode)
    }

    func testOthersReadWrite() {
        var mode: FileMode = .others([.read, .write])
        XCTAssertEqual(mode.rawValue, 0o6)
        mode = .others(.readWrite)
        XCTAssertEqual(mode.rawValue, 0o6)
        XCTAssertEqual(FileMode("-------rw-"), mode)
        XCTAssertEqual("-------rw-", mode)
    }

    func testOthersReadExecute() {
        var mode: FileMode = .others([.read, .execute])
        XCTAssertEqual(mode.rawValue, 0o5)
        mode = .others(.readExecute)
        XCTAssertEqual(mode.rawValue, 0o5)
        XCTAssertEqual(FileMode("-------r-x"), mode)
        XCTAssertEqual("-------r-x", mode)
    }

    func testOthersWriteExecute() {
        var mode: FileMode = .others([.write, .execute])
        XCTAssertEqual(mode.rawValue, 0o3)
        mode = .others(.writeExecute)
        XCTAssertEqual(mode.rawValue, 0o3)
        XCTAssertEqual(FileMode("--------wx"), mode)
        XCTAssertEqual("--------wx", mode)
    }

    func testOthersReadWriteExecute() {
        var mode: FileMode = .others([.read, .write, .execute])
        XCTAssertEqual(mode.rawValue, 0o7)
        mode = .others(.readWriteExecute)
        XCTAssertEqual(mode.rawValue, 0o7)
        XCTAssertEqual(FileMode("-------rwx"), mode)
        XCTAssertEqual("-------rwx", mode)
    }

    func testOwnerGroupRead() {
        let mode: FileMode = .ownerGroup(.read)
        XCTAssertEqual(mode.rawValue, 0o440)
        XCTAssertEqual(FileMode("-r--r-----"), mode)
        XCTAssertEqual("-r--r-----", mode)
    }

    func testOwnerGroupWrite() {
        let mode: FileMode = .ownerGroup(.write)
        XCTAssertEqual(mode.rawValue, 0o220)
        XCTAssertEqual(FileMode("--w--w----"), mode)
        XCTAssertEqual("--w--w----", mode)
    }

    func testOwnerGroupExecute() {
        let mode: FileMode = .ownerGroup(.execute)
        XCTAssertEqual(mode.rawValue, 0o110)
        XCTAssertEqual(FileMode("---x--x---"), mode)
        XCTAssertEqual("---x--x---", mode)
    }

    func testOwnerGroupReadWrite() {
        var mode: FileMode = .ownerGroup([.read, .write])
        XCTAssertEqual(mode.rawValue, 0o660)
        mode = .ownerGroup(.readWrite)
        XCTAssertEqual(mode.rawValue, 0o660)
        XCTAssertEqual(FileMode("-rw-rw----"), mode)
        XCTAssertEqual("-rw-rw----", mode)
    }

    func testOwnerGroupReadExecute() {
        var mode: FileMode = .ownerGroup([.read, .execute])
        XCTAssertEqual(mode.rawValue, 0o550)
        mode = .ownerGroup(.readExecute)
        XCTAssertEqual(mode.rawValue, 0o550)
        XCTAssertEqual(FileMode("-r-xr-x---"), mode)
        XCTAssertEqual("-r-xr-x---", mode)
    }

    func testOwnerGroupWriteExecute() {
        var mode: FileMode = .ownerGroup([.write, .execute])
        XCTAssertEqual(mode.rawValue, 0o330)
        mode = .ownerGroup(.writeExecute)
        XCTAssertEqual(mode.rawValue, 0o330)
        XCTAssertEqual(FileMode("--wx-wx---"), mode)
        XCTAssertEqual("--wx-wx---", mode)
    }

    func testOwnerGroupReadWriteExecute() {
        var mode: FileMode = .ownerGroup([.read, .write, .execute])
        XCTAssertEqual(mode.rawValue, 0o770)
        mode = .ownerGroup(.readWriteExecute)
        XCTAssertEqual(mode.rawValue, 0o770)
        XCTAssertEqual(FileMode("-rwxrwx---"), mode)
        XCTAssertEqual("-rwxrwx---", mode)
    }

    func testOwnerOthersRead() {
        let mode: FileMode = .ownerOthers(.read)
        XCTAssertEqual(mode.rawValue, 0o404)
        XCTAssertEqual(FileMode("-r-----r--"), mode)
        XCTAssertEqual("-r-----r--", mode)
    }

    func testOwnerOthersWrite() {
        let mode: FileMode = .ownerOthers(.write)
        XCTAssertEqual(mode.rawValue, 0o202)
        XCTAssertEqual(FileMode("--w-----w-"), mode)
        XCTAssertEqual("--w-----w-", mode)
    }

    func testOwnerOthersExecute() {
        let mode: FileMode = .ownerOthers(.execute)
        XCTAssertEqual(mode.rawValue, 0o101)
        XCTAssertEqual(FileMode("---x-----x"), mode)
        XCTAssertEqual("---x-----x", mode)
    }

    func testOwnerOthersReadWrite() {
        var mode: FileMode = .ownerOthers([.read, .write])
        XCTAssertEqual(mode.rawValue, 0o606)
        mode = .ownerOthers(.readWrite)
        XCTAssertEqual(mode.rawValue, 0o606)
        XCTAssertEqual(FileMode("-rw----rw-"), mode)
        XCTAssertEqual("-rw----rw-", mode)
    }

    func testOwnerOthersReadExecute() {
        var mode: FileMode = .ownerOthers([.read, .execute])
        XCTAssertEqual(mode.rawValue, 0o505)
        mode = .ownerOthers(.readExecute)
        XCTAssertEqual(mode.rawValue, 0o505)
        XCTAssertEqual(FileMode("-r-x---r-x"), mode)
        XCTAssertEqual("-r-x---r-x", mode)
    }

    func testOwnerOthersWriteExecute() {
        var mode: FileMode = .ownerOthers([.write, .execute])
        XCTAssertEqual(mode.rawValue, 0o303)
        mode = .ownerOthers(.writeExecute)
        XCTAssertEqual(mode.rawValue, 0o303)
        XCTAssertEqual(FileMode("--wx----wx"), mode)
        XCTAssertEqual("--wx----wx", mode)
    }

    func testOwnerOthersReadWriteExecute() {
        var mode: FileMode = .ownerOthers([.read, .write, .execute])
        XCTAssertEqual(mode.rawValue, 0o707)
        mode = .ownerOthers(.readWriteExecute)
        XCTAssertEqual(mode.rawValue, 0o707)
        XCTAssertEqual(FileMode("-rwx---rwx"), mode)
        XCTAssertEqual("-rwx---rwx", mode)
    }

    func testGroupOthersRead() {
        let mode: FileMode = .groupOthers(.read)
        XCTAssertEqual(mode.rawValue, 0o44)
        XCTAssertEqual(FileMode("----r--r--"), mode)
        XCTAssertEqual("----r--r--", mode)
    }

    func testGroupOthersWrite() {
        let mode: FileMode = .groupOthers(.write)
        XCTAssertEqual(mode.rawValue, 0o22)
        XCTAssertEqual(FileMode("-----w--w-"), mode)
        XCTAssertEqual("-----w--w-", mode)
    }

    func testGroupOthersExecute() {
        let mode: FileMode = .groupOthers(.execute)
        XCTAssertEqual(mode.rawValue, 0o11)
        XCTAssertEqual(FileMode("------x--x"), mode)
        XCTAssertEqual("------x--x", mode)
    }

    func testGroupOthersReadWrite() {
        var mode: FileMode = .groupOthers([.read, .write])
        XCTAssertEqual(mode.rawValue, 0o66)
        mode = .groupOthers(.readWrite)
        XCTAssertEqual(mode.rawValue, 0o66)
        XCTAssertEqual(FileMode("----rw-rw-"), mode)
        XCTAssertEqual("----rw-rw-", mode)
    }

    func testGroupOthersReadExecute() {
        var mode: FileMode = .groupOthers([.read, .execute])
        XCTAssertEqual(mode.rawValue, 0o55)
        mode = .groupOthers(.readExecute)
        XCTAssertEqual(mode.rawValue, 0o55)
        XCTAssertEqual(FileMode("----r-xr-x"), mode)
        XCTAssertEqual("----r-xr-x", mode)
    }

    func testGroupOthersWriteExecute() {
        var mode: FileMode = .groupOthers([.write, .execute])
        XCTAssertEqual(mode.rawValue, 0o33)
        mode = .groupOthers(.writeExecute)
        XCTAssertEqual(mode.rawValue, 0o33)
        XCTAssertEqual(FileMode("-----wx-wx"), mode)
        XCTAssertEqual("-----wx-wx", mode)
    }

    func testGroupOthersReadWriteExecute() {
        var mode: FileMode = .groupOthers([.read, .write, .execute])
        XCTAssertEqual(mode.rawValue, 0o77)
        mode = .groupOthers(.readWriteExecute)
        XCTAssertEqual(mode.rawValue, 0o77)
        XCTAssertEqual(FileMode("----rwxrwx"), mode)
        XCTAssertEqual("----rwxrwx", mode)
    }

    func testOwnerGroupOthersRead() {
        let mode: FileMode = .ownerGroupOthers(.read)
        XCTAssertEqual(mode.rawValue, 0o444)
        XCTAssertEqual(FileMode("-r--r--r--"), mode)
        XCTAssertEqual("-r--r--r--", mode)
    }

    func testOwnerGroupOthersWrite() {
        let mode: FileMode = .ownerGroupOthers(.write)
        XCTAssertEqual(mode.rawValue, 0o222)
        XCTAssertEqual(FileMode("--w--w--w-"), mode)
        XCTAssertEqual("--w--w--w-", mode)
    }

    func testOwnerGroupOthersExecute() {
        let mode: FileMode = .ownerGroupOthers(.execute)
        XCTAssertEqual(mode.rawValue, 0o111)
        XCTAssertEqual(FileMode("---x--x--x"), mode)
        XCTAssertEqual("---x--x--x", mode)
    }

    func testOwnerGroupOthersReadWrite() {
        var mode: FileMode = .ownerGroupOthers([.read, .write])
        XCTAssertEqual(mode.rawValue, 0o666)
        mode = .ownerGroupOthers(.readWrite)
        XCTAssertEqual(mode.rawValue, 0o666)
        XCTAssertEqual(FileMode("-rw-rw-rw-"), mode)
        XCTAssertEqual("-rw-rw-rw-", mode)
    }

    func testOwnerGroupOthersReadExecute() {
        var mode: FileMode = .ownerGroupOthers([.read, .execute])
        XCTAssertEqual(mode.rawValue, 0o555)
        mode = .ownerGroupOthers(.readExecute)
        XCTAssertEqual(mode.rawValue, 0o555)
        XCTAssertEqual(FileMode("-r-xr-xr-x"), mode)
        XCTAssertEqual("-r-xr-xr-x", mode)
    }

    func testOwnerGroupOthersWriteExecute() {
        var mode: FileMode = .ownerGroupOthers([.write, .execute])
        XCTAssertEqual(mode.rawValue, 0o333)
        mode = .ownerGroupOthers(.writeExecute)
        XCTAssertEqual(mode.rawValue, 0o333)
        XCTAssertEqual(FileMode("--wx-wx-wx"), mode)
        XCTAssertEqual("--wx-wx-wx", mode)
    }

    func testOwnerGroupOthersReadWriteExecute() {
        var mode: FileMode = .ownerGroupOthers([.read, .write, .execute])
        XCTAssertEqual(mode.rawValue, 0o777)
        mode = .ownerGroupOthers(.readWriteExecute)
        XCTAssertEqual(mode.rawValue, 0o777)
        XCTAssertEqual(FileMode("-rwxrwxrwx"), mode)
        XCTAssertEqual("-rwxrwxrwx", mode)
    }

    func testUidBit() {
        let mode: FileMode = .allPermissions | FileBits.uid
        XCTAssertEqual(mode.rawValue, 0o4777)
        XCTAssertEqual(mode, FileMode("-rwSrwxrwx"))
        XCTAssertEqual(mode, "-rwSrwxrwx")
    }

    func testGidBit() {
        let mode: FileMode = .allPermissions | FileBits.gid
        XCTAssertEqual(mode.rawValue, 0o2777)
        XCTAssertEqual(mode, FileMode("-rwxrwSrwx"))
        XCTAssertEqual(mode, "-rwxrwSrwx")
    }

    func testStickyBit() {
        var mode: FileMode = .allPermissions | FileBits.sticky
        XCTAssertEqual(mode.rawValue, 0o1777)
        XCTAssertEqual(mode, FileMode("-rwxrwxrwt"))
        XCTAssertEqual(mode, "-rwxrwxrwt")
        mode &= ~.others(.execute)
        XCTAssertEqual(mode.rawValue, 0o1776)
        XCTAssertEqual(mode, FileMode("-rwxrwxrwT"))
        XCTAssertEqual(mode, "-rwxrwxrwT")
    }

    func testUidGidBits() {
        let mode: FileMode = .allPermissions | FileBits(.uid, .gid)
        XCTAssertEqual(mode.rawValue, 0o6777)
        XCTAssertEqual(mode, FileMode("-rwSrwSrwx"))
        XCTAssertEqual(mode, "-rwSrwSrwx")
    }

    func testUidStickyBits() {
        var mode: FileMode = .allPermissions | FileBits(.uid, .sticky)
        XCTAssertEqual(mode.rawValue, 0o5777)
        XCTAssertEqual(mode, FileMode("-rwSrwxrwt"))
        XCTAssertEqual(mode, "-rwSrwxrwt")
        mode &= ~.others(.execute)
        XCTAssertEqual(mode.rawValue, 0o5776)
        XCTAssertEqual(mode, FileMode("-rwSrwxrwT"))
        XCTAssertEqual(mode, "-rwSrwxrwT")
    }

    func testGidStickyBits() {
        var mode: FileMode = .allPermissions | FileBits(.gid, .sticky)
        XCTAssertEqual(mode.rawValue, 0o3777)
        XCTAssertEqual(mode, FileMode("-rwxrwSrwt"))
        XCTAssertEqual(mode, "-rwxrwSrwt")
        mode &= ~.others(.execute)
        XCTAssertEqual(mode.rawValue, 0o3776)
        XCTAssertEqual(mode, FileMode("-rwxrwSrwT"))
        XCTAssertEqual(mode, "-rwxrwSrwT")
    }

    func testUidGidStickyBits() {
        var mode: FileMode = .allPermissions | FileBits.all
        XCTAssertEqual(mode.rawValue, 0o7777)
        XCTAssertEqual(mode, FileMode("-rwSrwSrwt"))
        XCTAssertEqual(mode, "-rwSrwSrwt")
        mode &= ~.others(.execute)
        XCTAssertEqual(mode.rawValue, 0o7776)
        XCTAssertEqual(mode, FileMode("-rwSrwSrwT"))
        XCTAssertEqual(mode, "-rwSrwSrwT")
    }

    func testOSStrings() {
        let mode1: FileMode = "rwxrwxrwx"
        let mode2: FileMode = "-rwxrwxrwx"
        let mode3: FileMode = "-rwxrwxrwx@"
        let mode4: FileMode = "-rwxrwxrwx+"
        let mode5: FileMode = "-rwxrwxrwx "

        XCTAssertEqual(mode1, mode2)
        XCTAssertEqual(mode2, mode3)
        XCTAssertEqual(mode3, mode4)
        XCTAssertEqual(mode4, mode5)
    }

    func testUMask() {
        let originalUMask = umask
        setUMask(for: .none)

        XCTAssertEqual(umask, .allPermissions)
        XCTAssertEqual(originalUMask, lastUMask)

        resetUMask()

        XCTAssertEqual(umask, originalUMask)
        XCTAssertEqual(lastUMask, .allPermissions)
    }

    func testUnmask() {
        setUMask(for: .none)
        defer { resetUMask() }
        var mode: FileMode = .all
        mode.unmask()
        XCTAssertNotEqual(mode, .all)
        XCTAssertEqual(mode, FileMode.all.unmasked())
    }

    func testOrOperator() {
        let ownerAll: FileMode = .owner(.all)
        let groupAll: FileMode = .group(.all)
        let ownerGroupAll: FileMode = .ownerGroup(.all)
        var empty: FileMode = .none

        XCTAssertEqual(ownerAll | groupAll, ownerGroupAll)
        XCTAssertEqual(ownerAll | groupAll.rawValue, ownerGroupAll)

        XCTAssertNotEqual(empty, ownerGroupAll)
        empty |= ownerAll
        XCTAssertEqual(empty, ownerAll)
        empty |= groupAll
        XCTAssertEqual(empty, ownerGroupAll)
    }

    func testAndOperator() {
        let ownerAll: FileMode = .owner(.all)
        let groupAll: FileMode = .group(.all)
        var ownerGroupAll: FileMode = .ownerGroup(.all)
        let empty: FileMode = .none

        XCTAssertEqual(ownerGroupAll & ownerAll, ownerAll)
        XCTAssertEqual(ownerGroupAll & ownerAll.rawValue, ownerAll)

        XCTAssertNotEqual(empty, ownerGroupAll)
        ownerGroupAll &= groupAll
        XCTAssertEqual(ownerGroupAll, groupAll)
        ownerGroupAll &= ownerAll
        XCTAssertEqual(empty, ownerGroupAll)
    }

    func testCustomStringConvertible() {
        let allPermissions: FileMode = .allPermissions
        let perms: FilePermissions = .all
        let noPerms: FilePermissions = .none
        let allBits: FileMode = .allBits
        let bits: FileBits = .all
        let noBits: FileBits = .none

        XCTAssertEqual(allPermissions.description, "FileMode(owner: \(perms), group: \(perms), others: \(perms), bits: \(noBits))")
        XCTAssertEqual(allBits.description, "FileMode(owner: \(noPerms), group: \(noPerms), others: \(noPerms), bits: \(bits))")
    }

    #if os(Linux)
    static let allTests = [
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
        ("testOSStrings", testOSStrings),
        ("testUMask", testUMask),
        ("testUnmask", testUnmask),
        ("testOrOperator", testOrOperator),
        ("testAndOperator", testAndOperator),
        ("testCustomStringConvertable", testCustomStringConvertible),
        ("testUidBit", testUidBit),
        ("testGidBit", testGidBit),
        ("testStickyBit", testStickyBit),
        ("testUidGidBits", testUidGidBits),
        ("testUidStickyBits", testUidStickyBits),
        ("testGidStickyBits", testGidStickyBits),
        ("testUidGidStickyBits", testUidGidStickyBits),
    ]
    #endif
}
