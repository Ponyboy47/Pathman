@testable import PathMan
import XCTest

class GlobTests: XCTestCase {
    func testGlob() {
        do {
            let glob = try PathMan.glob(pattern: "/tmp/*")
            XCTAssertFalse(glob.matches.isEmpty)
        } catch {
            XCTFail("Glob threw an error: \(error)")
        }
    }

    func testGlobDirectory() {
        guard let tmp = DirectoryPath("/tmp") else {
            return XCTFail("Failed to get the home directory")
        }

        do {
            let glob = try tmp.glob(pattern: "*")
            XCTAssertFalse(glob.matches.isEmpty)
        } catch {
            XCTFail("Glob threw an error: \(error)")
        }
    }

    func testGlobFlagsInit() {
        let flags1 = GlobFlags(.unsorted, .brace, .tilde)
        let flags2 = GlobFlags(integerLiteral: flags1.rawValue)
        XCTAssertEqual(flags1, flags2)
    }

    func testGlobFlagsCustomStringConvertible() {
        let flags = GlobFlags(integerLiteral: .max)

        #if os(Linux)
        let osFlags = ", period, tildeCheck, onlyDirectories"
        #else
        let osFlags = ", containsGlobbingCharacters, limit"
        #endif

        XCTAssertEqual(flags.description, "GlobFlags(error, unsorted, offset, noCheck, append, noEscape, alternativeDirectoryFunctions, brace, noMagic, tilde\(osFlags))")

        let other: GlobFlags = 0
        XCTAssertEqual(other.description, "GlobFlags(none)")
    }
}
