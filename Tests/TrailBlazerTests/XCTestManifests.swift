import XCTest

extension ChmodTests {
    static let __allTests = [
        ("testSetOwner", testSetOwner),
        ("testSetGroup", testSetGroup),
        ("testSetOthers", testSetOthers),
        ("testSetOwnerGroup", testSetOwnerGroup),
        ("testSetOwnerOthers", testSetOwnerOthers),
        ("testSetGroupOthers", testSetGroupOthers),
        ("testSetOwnerGroupOthers", testSetOwnerGroupOthers),
        ("testSetProperties", testSetProperties),
    ]
}

extension CopyTests {
    static let __allTests = [
        ("testCopyFile", testCopyFile),
        ("testCopyDirectoryEmpty", testCopyDirectoryEmpty),
        ("testCopyDirectoryNotEmpty", testCopyDirectoryNotEmpty),
        ("testCopyDirectoryRecursive", testCopyDirectoryRecursive),
    ]
}

extension CreateDeleteTests {
    static let __allTests = [
        ("testCreateFile", testCreateFile),
        ("testDeleteFile", testDeleteFile),
        ("testCreateDirectory", testCreateDirectory),
        ("testDeleteDirectory", testDeleteDirectory),
        ("testDeleteNonEmptyDirectory", testDeleteNonEmptyDirectory),
        ("testDeleteDirectoryRecursive", testDeleteDirectoryRecursive),
        ("testCreateIntermediates", testCreateIntermediates),
    ]
}

extension FileBitsTests {
    static let __allTests = [
        ("testHasNone", testHasNone),
        ("testEquality", testEquality),
        ("testContains", testContains),
        ("testCustomStringConvertible", testCustomStringConvertible),
    ]
}

extension FileModeTests {
    static let __allTests = [
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
        ("testCustomStringConvertible", testCustomStringConvertible),
        ("testUidBit", testUidBit),
        ("testGidBit", testGidBit),
        ("testStickyBit", testStickyBit),
        ("testUidGidBits", testUidGidBits),
        ("testUidStickyBits", testUidStickyBits),
        ("testGidStickyBits", testGidStickyBits),
        ("testUidGidStickyBits", testUidGidStickyBits),
        ("testSetFileBits", testSetFileBits),
    ]
}

extension FilePermissionsTests {
    static let __allTests = [
        ("testRead", testRead),
        ("testWrite", testWrite),
        ("testExecute", testExecute),
        ("testNone", testNone),
        ("testReadWrite", testReadWrite),
        ("testReadExecute", testReadExecute),
        ("testWriteExecute", testWriteExecute),
        ("testReadWriteExecute", testReadWriteExecute),
    ]
}

extension GlobTests {
    static let __allTests = [
        ("testGlob", testGlob),
        ("testGlobDirectory", testGlobDirectory),
        ("testGlobFlagsInit", testGlobFlagsInit),
        ("testGlobFlagsCustomStringConvertible", testGlobFlagsCustomStringConvertible),
    ]
}

extension LinkTests {
    static let __allTests = [
        ("testAbsoluteSoftLink", testAbsoluteSoftLink),
        ("testRelativeSoftLink", testRelativeSoftLink),
        ("testAbsoluteHardLink", testAbsoluteHardLink),
        ("testRelativeHardLink", testRelativeHardLink),
    ]
}

extension MoveTests {
    static let __allTests = [
        ("testMove", testMove),
        ("testRename", testRename),
        ("testMoveInto", testMoveInto),
    ]
}

extension OpenTests {
    static let __allTests = [
        ("testOpenFile", testOpenFile),
        ("testReadFile", testReadFile),
        ("testWriteFile", testWriteFile),
        ("testOpenDirectory", testOpenDirectory),
        ("testGetDirectoryChildren", testGetDirectoryChildren),
        ("testOpenFileFlagsCustomStringConvertible", testOpenFileFlagsCustomStringConvertible),
        ("testOpenFilePermissionsCustomStringConvertible", testOpenFilePermissionsCustomStringConvertible),
    ]
}

extension PathCollectionTests {
    static let __allTests = [
        ("testEmpty", testEmpty),
        ("testNotEmpty", testNotEmpty),
        ("testPlus", testPlus),
        ("testPlusEqual", testPlusEqual),
        ("testEquality", testEquality),
    ]
}

extension PathTests {
    static let __allTests = [
        ("testStringInit", testStringInit),
        ("testPathInit", testPathInit),
        ("testArrayInit", testArrayInit),
        ("testArraySliceInit", testArraySliceInit),
        ("testStringLiteral", testStringLiteral),
        ("testArrayLiteral", testArrayLiteral),
        ("testChRoot", testChRoot),
        ("testChCWD", testChCWD),
        ("testComponents", testComponents),
        ("testLastComponent", testLastComponent),
        ("testParent", testParent),
        ("testExists", testExists),
        ("testCustomStringConvertible", testCustomStringConvertible),
        ("testEquatable", testEquatable),
        ("testAddable", testAddable),
        ("testAbsolute", testAbsolute),
        ("testExpand", testExpand),
        ("testRelative", testRelative),
        ("testPathType", testPathType),
    ]
}

extension StatTests {
    static let __allTests = [
        ("testInit", testInit),
        ("testType", testType),
        ("testID", testID),
        ("testInode", testInode),
        ("testPermissions", testPermissions),
        ("testOwner", testOwner),
        ("testGroup", testGroup),
        ("testSize", testSize),
        ("testDevice", testDevice),
        ("testBlockSize", testBlockSize),
        ("testBlocks", testBlocks),
        ("testAccess", testAccess),
        ("testModified", testModified),
        ("testAttributeChange", testAttributeChange),
    ]
}

extension TemporaryTests {
    static let __allTests = [
        ("testTemporaryFile", testTemporaryFile),
        ("testTemporaryDirectory", testTemporaryDirectory),
    ]
}

extension UtilityTests {
    static let __allTests = [
        ("testKilobytes", testKilobytes),
        ("testMegabytes", testMegabytes),
        ("testGigabytes", testGigabytes),
        ("testTerabytes", testTerabytes),
        ("testPetabytes", testPetabytes),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FilePermissionsTests.__allTests),
        testCase(FileModeTests.__allTests),
        testCase(FileBitsTests.__allTests),
        testCase(PathTests.__allTests),
        testCase(StatTests.__allTests),
        testCase(OpenTests.__allTests),
        testCase(CreateDeleteTests.__allTests),
        testCase(ChmodTests.__allTests),
        testCase(MoveTests.__allTests),
        testCase(GlobTests.__allTests),
        testCase(TemporaryTests.__allTests),
        testCase(LinkTests.__allTests),
        testCase(CopyTests.__allTests),
        testCase(PathCollectionTests.__allTests),
        testCase(UtilityTests.__allTests),
    ]
}
#endif
