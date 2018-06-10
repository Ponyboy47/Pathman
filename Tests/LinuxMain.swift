import XCTest
@testable import TrailBlazerTests

XCTMain([
    testCase(FilePermissionsTests.allTests),
    testCase(FileModeTests.allTests),
    testCase(PathTests.allTests),
    testCase(StatTests.allTests),
    testCase(OpenTests.allTests),
    testCase(CreateDeleteTests.allTests),
])
