#if os(Linux)
import typealias Glibc.sa_family_t
import struct Glibc.sockaddr
import struct Glibc.sockaddr_un
import typealias Glibc.socklen_t
import func Glibc.strncpy
#else
import typealias Darwin.sa_family_t
import struct Darwin.sockaddr
import struct Darwin.sockaddr_un
import typealias Darwin.socklen_t
import func Darwin.strncpy
#endif

public typealias SocketAddress = sockaddr
public typealias SocketAddressSize = socklen_t
public typealias LocalSocketAddress = sockaddr_un
public typealias UnixSocketAddress = LocalSocketAddress
public typealias SocketFamily = sa_family_t

public struct SocketPath: Path {
    public static let pathType: PathType = .socket
    public static let emptyReadFlags: ReceiveFlags = .none
    public static let emptyWriteFlags: SendFlags = .none

    // swiftlint:disable identifier_name
    public var _path: String

    public let _info: StatInfo

    #if os(Linux)
    public static let PATH_MAX = 108
    #else
    public static let PATH_MAX = 104
    #endif
    // swiftlint:enable identifier_name

    /**
     Initialize from another Path

     - Parameter path: The path to copy
     */
    public init(_ path: GenericPath) {
        _path = path._path
        _info = StatInfo(path)
        try? _info.getInfo()
    }

    private func generateLocalSocketAddressPointer() -> UnsafeMutablePointer<LocalSocketAddress> {
        let ptr = UnsafeMutablePointer<LocalSocketAddress>.allocate(capacity: 1)
        ptr.pointee = LocalSocketAddress()
        ptr.pointee.sun_family = SocketFamily(SocketDomain.local.rawValue)
        return ptr
    }

    public func convertToCAddress() throws -> UnsafePointer<SocketAddress> {
        guard string.count < SocketPath.PATH_MAX - 1 else {
            throw LocalAddressError.pathnameTooLong
        }

        let addr = generateLocalSocketAddressPointer()

        let strlen = MemoryLayout.size(ofValue: addr.pointee.sun_path)
        withUnsafeMutablePointer(to: &addr.pointee.sun_path) {
            $0.withMemoryRebound(to: Int8.self, capacity: strlen) {
                _ = strncpy($0, string, strlen)
            }
        }

        return UnsafeRawPointer(addr).assumingMemoryBound(to: SocketAddress.self)
    }

    @available(*, unavailable, message: "Cannot append to a SocketPath")
    public static func + <PathType: Path>(_: SocketPath, _: PathType) -> PathType {
        fatalError("Cannot append to a SocketPath")
    }
}
