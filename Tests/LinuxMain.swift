import XCTest
@testable import TrailBlazerTests

#if os(Linux)
import Glibc
#else
import Darwin
#endif

XCTMain([
    testCase(FilePermissionsTests.allTests),
    testCase(FileModeTests.allTests),
    testCase(PathTests.allTests),
    testCase(StatTests.allTests),
    testCase(OpenTests.allTests),
    testCase(CreateDeleteTests.allTests),
    // Can't set the owner unless you're a privileged user, like root (uid == 0)
    // Can't set the group unless you're a privileged user, like root (uid
    // == 0) or if youre changing the group to one of the groups you are a
    // part of (too much work to get the list of groups the process's user
    // is a part of)
    testCase(geteuid() == 0 ? ChownTests.allTests : []),
    testCase(ChmodTests.allTests),
    testCase(MoveTests.allTests),
    testCase(GlobTests.allTests),
    testCase(TemporaryTests.allTests),
])
