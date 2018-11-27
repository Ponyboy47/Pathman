import XCTest
import Dispatch
@testable import TrailBlazer

class BindingTests: XCTestCase {
    func testAccepting() {
        let socket = SocketPath("/tmp/com.trailblazer.sock")!

        var binding: Binding?
        do {
            binding = try socket.bind()
        } catch {
            XCTFail("Failed to bind to socket with error \(error)")
            return
        }

        XCTAssertNoThrow(try binding?.listen(maxQueued: 1))

        #if os(macOS)
        let acceptConnection = expectation(description: "Ensure connection is properly accepted")
        #endif

        DispatchQueue.global(qos: .background).async {
            do {
                try binding?.accept { conn in
                    #if os(macOS)
                    acceptConnection.fulfill()
                    #endif
                    XCTAssertEqual(conn, conn)
                    XCTAssertNotEqual(conn.hashValue, 0)
                    XCTAssertTrue(conn.description.count > 30)

                    do {
                        _ = try conn.read(flags: .dontWait)
                        XCTFail("Reading a connection did not wait")
                    } catch {}
                }
            } catch {
                XCTFail("Failed to accept connection with error \(type(of: error)).\(error)")
            }
        }

        XCTAssertNoThrow(try socket.connect(type: .stream))
        #if os(macOS)
        wait(for: [acceptConnection], timeout: 5.0)
        #endif

        binding = nil
    }

    func testEquatable() {
        let socket1 = SocketPath("/tmp/com.trailblazer.sock1")!
        let socket2 = SocketPath("/tmp/com.trailblazer.sock2")!

        do {
            let bind1 = try socket1.bind()
            let bind2 = try socket2.bind()

            XCTAssertNotEqual(bind1, bind2)
        } catch {
            XCTFail("Failed to bind one of the sockets")
        }
    }

    func testHashable() {
        let socket1 = SocketPath("/tmp/com.trailblazer.sock1")!
        let socket2 = SocketPath("/tmp/com.trailblazer.sock2")!

        do {
            let bind1 = try socket1.bind()
            let bind2 = try socket2.bind()

            XCTAssertNotEqual(bind1.hashValue, bind2.hashValue)
        } catch {
            XCTFail("Failed to bind one of the sockets")
        }
    }

    func testCustomStringConvertible() {
        let socket = SocketPath("/tmp/com.trailblazer.sock1")!

        let binding: Binding
        do {
            binding = try socket.bind()
        } catch {
            XCTFail("Failed to bind to socket with error \(error)")
            return
        }

        // swiftlint:disable line_length
        XCTAssertEqual(binding.description, "Binding(path: SocketPath(\"/tmp/com.trailblazer.sock1\"), options: SocketOptions(domain: SocketDomain.local, type: SocketType.stream))")
    }
}
