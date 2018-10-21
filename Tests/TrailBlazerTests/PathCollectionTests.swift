import XCTest
@testable import TrailBlazer

class PathCollectionTests: XCTestCase {
    let emptyChildren = PathCollection()
    let children1 = PathCollection(files: [FilePath("com.trailblazer.test.f1")!], directories: [DirectoryPath("com.trailblazer.test.d1")!], other: [GenericPath(FilePath("com.trailblazer.test.f2")!), GenericPath(DirectoryPath("com.trailblazer.test.d2")!)])
    let children2 = PathCollection(files: [FilePath("com.trailblazer.test.f3")!], directories: [DirectoryPath("com.trailblazer.test.d3")!], other: [GenericPath(FilePath("com.trailblazer.test.f2")!), GenericPath(DirectoryPath("com.trailblazer.test.d2")!)])

    func testEmpty() {
        XCTAssertTrue(emptyChildren.isEmpty)
        XCTAssertEqual(emptyChildren.count, 0)
        XCTAssertEqual(emptyChildren.description, "PathCollection(files: [], directories: [], other: [])")
    }

    func testNotEmpty() {
        XCTAssertFalse(children1.isEmpty)
        XCTAssertEqual(children1.count, 4)
        XCTAssertEqual(children1.description, "PathCollection(files: [FilePath(\"com.trailblazer.test.f1\")], directories: [DirectoryPath(\"com.trailblazer.test.d1\")], other: [GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\")])")
    }

    func testPlus() {
        let combinedChildren = children1 + children2
        XCTAssertEqual(combinedChildren.count, 8)
        XCTAssertEqual(combinedChildren.description, "PathCollection(files: [FilePath(\"com.trailblazer.test.f1\"), FilePath(\"com.trailblazer.test.f3\")], directories: [DirectoryPath(\"com.trailblazer.test.d1\"), DirectoryPath(\"com.trailblazer.test.d3\")], other: [GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\"), GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\")])")
    }

    func testPlusEqual() {
        var pE = PathCollection()
        XCTAssertTrue(pE.isEmpty)
        XCTAssertEqual(pE.count, 0)
        XCTAssertEqual(pE.description, "PathCollection(files: [], directories: [], other: [])")
        pE += children1
        XCTAssertFalse(pE.isEmpty)
        XCTAssertEqual(pE.count, 4)
        XCTAssertEqual(pE.description, "PathCollection(files: [FilePath(\"com.trailblazer.test.f1\")], directories: [DirectoryPath(\"com.trailblazer.test.d1\")], other: [GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\")])")
        pE += children2
        XCTAssertEqual(pE.count, 8)
        XCTAssertEqual(pE.description, "PathCollection(files: [FilePath(\"com.trailblazer.test.f1\"), FilePath(\"com.trailblazer.test.f3\")], directories: [DirectoryPath(\"com.trailblazer.test.d1\"), DirectoryPath(\"com.trailblazer.test.d3\")], other: [GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\"), GenericPath(\"com.trailblazer.test.f2\"), GenericPath(\"com.trailblazer.test.d2\")])")
    }

    func testEquality() {
        XCTAssertNotEqual(emptyChildren, children1)
        XCTAssertNotEqual(emptyChildren, children2)
        XCTAssertNotEqual(children1, children2)

        let combinedChildren = children1 + children2
        var pE = PathCollection()
        pE += children1
        pE += children2
        XCTAssertEqual(pE, combinedChildren)

        pE = PathCollection()
        pE += children2
        pE += children1
        XCTAssertNotEqual(pE, combinedChildren)
    }
}
