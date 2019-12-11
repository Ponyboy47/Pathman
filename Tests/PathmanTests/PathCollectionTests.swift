@testable import Pathman
import XCTest

class DirectoryChildrenTests: XCTestCase {
    let emptyChildren = DirectoryChildren()
    let children1 = DirectoryChildren(files: [FilePath("com.trailblazer.test.f1")!], directories: [DirectoryPath("com.trailblazer.test.d1")!], other: [GenericPath(FilePath("com.trailblazer.test.f2")!), GenericPath(DirectoryPath("com.trailblazer.test.d2")!)])
    let children2 = DirectoryChildren(files: [FilePath("com.trailblazer.test.f3")!], directories: [DirectoryPath("com.trailblazer.test.d3")!], other: [GenericPath(FilePath("com.trailblazer.test.f2")!), GenericPath(DirectoryPath("com.trailblazer.test.d2")!)])

    func testEmpty() {
        XCTAssertTrue(emptyChildren.isEmpty)
        XCTAssertEqual(emptyChildren.count, 0)
        XCTAssertEqual(emptyChildren.description, "DirectoryChildren(files: [], directories: [], other: [])")
    }

    func testNotEmpty() {
        XCTAssertFalse(children1.isEmpty)
        XCTAssertEqual(children1.count, 4)
        XCTAssertEqual(children1.description, "DirectoryChildren(files: [FilePath(\"com.trailblazer.test.f1\")], directories: [DirectoryPath(\"com.trailblazer.test.d1\")], other: [GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\")])")
    }

    func testPlus() {
        let combinedChildren = children1 + children2
        XCTAssertEqual(combinedChildren.count, 8)
        XCTAssertEqual(combinedChildren.description, "DirectoryChildren(files: [FilePath(\"com.trailblazer.test.f1\"), FilePath(\"com.trailblazer.test.f3\")], directories: [DirectoryPath(\"com.trailblazer.test.d1\"), DirectoryPath(\"com.trailblazer.test.d3\")], other: [GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\"), GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\")])")
    }

    func testPlusEqual() {
        var pE = DirectoryChildren()
        XCTAssertTrue(pE.isEmpty)
        XCTAssertEqual(pE.count, 0)
        XCTAssertEqual(pE.description, "DirectoryChildren(files: [], directories: [], other: [])")
        pE += children1
        XCTAssertFalse(pE.isEmpty)
        XCTAssertEqual(pE.count, 4)
        XCTAssertEqual(pE.description, "DirectoryChildren(files: [FilePath(\"com.trailblazer.test.f1\")], directories: [DirectoryPath(\"com.trailblazer.test.d1\")], other: [GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\")])")
        pE += children2
        XCTAssertEqual(pE.count, 8)
        XCTAssertEqual(pE.description, "DirectoryChildren(files: [FilePath(\"com.trailblazer.test.f1\"), FilePath(\"com.trailblazer.test.f3\")], directories: [DirectoryPath(\"com.trailblazer.test.d1\"), DirectoryPath(\"com.trailblazer.test.d3\")], other: [GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\"), GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\")])")
    }

    func testEquality() {
        XCTAssertNotEqual(emptyChildren, children1)
        XCTAssertNotEqual(emptyChildren, children2)
        XCTAssertNotEqual(children1, children2)

        let combinedChildren = children1 + children2
        var pE = DirectoryChildren()
        pE += children1
        pE += children2
        XCTAssertEqual(pE, combinedChildren)

        pE = DirectoryChildren()
        pE += children2
        pE += children1
        XCTAssertNotEqual(pE, combinedChildren)
    }
}
