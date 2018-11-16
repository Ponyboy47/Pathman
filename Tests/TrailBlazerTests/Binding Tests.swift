import XCTest
import Dispatch
@testable import TrailBlazer

class BindingTests: XCTestCase {
    func testAccepting() {
        let socket = SocketPath("/tmp/com.trailblazer.sock")!

        let binding: Binding
        do {
            binding = try socket.bind()
        } catch {
            XCTFail("Failed to bind to socket with error \(error)")
            return
        }

        #if os(macOS)
        XCTAssertNoThrow(try binding.listen(maxQueued: 1))

        let acceptConnection = XCTestExpectation(description: "Ensure connection is properly accepted")

        DispatchQueue.global(qos: .background).async {
            do {
                try binding.accept { _ in
                    acceptConnection.fulfill()
                }
            } catch {
                print("Failed to accept connection with error \(type(of: error)).\(error)")
            }
        }

        XCTAssertNoThrow(try socket.connect(type: .stream))

        XCTAssertEqual(XCTWaiter.wait(for: [acceptConnection], timeout: 5.0), .completed)
        #endif
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
        let socket = SocketPath("/tmp/com.trailblazer.sock")!

        let binding: Binding
        do {
            binding = try socket.bind()
        } catch {
            XCTFail("Failed to bind to socket with error \(error)")
            return
        }

        XCTAssertEqual(binding.description, "Binding(path: SocketPath(\"/tmp/com.trailblazer.sock\"), options: SocketOptions(domain: SocketDomain.local, type: SocketType.stream))")
    }
}
