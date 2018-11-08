#if os(Linux)
import struct Glibc.sockaddr
import struct Glibc.sockaddr_un
import typealias Glibc.socklen_t
import func Glibc.strncpy
#else
import struct Darwin.sockaddr
import struct Darwin.sockaddr_un
import typealias Darwin.socklen_t
import func Darwin.strncpy
import let Darwin.PF_UNIX
#endif

public typealias SocketAddress = sockaddr
public typealias SocketAddressSize = socklen_t
public typealias LocalSocketAddress = sockaddr_un
public typealias UnixSocketAddress = LocalSocketAddress

public protocol Address {
    func convertToConnectableAddress() throws -> (SocketAddress, SocketAddressSize)
}

public protocol DomainRestrictedAddress: Address {
    associatedtype AddressType

    static var validDomains: [SocketDomain] { get }
    static var defaultDomain: SocketDomain { get }

    var domain: SocketDomain { get set }
    var address: AddressType { get }

    /// Initializes an Address using the default domain
    init(address: AddressType)
}

extension DomainRestrictedAddress {
    public init(domain: SocketDomain, address: AddressType) throws {
        guard Self.validDomains.contains(domain) else { throw AddressError.invalidDomain }

        self.init(address: address)
        self.domain = domain
    }
}

public struct LocalAddress: DomainRestrictedAddress {
    #if os(Linux)
    public static let validDomains: [SocketDomain] = [.unix, .local]
    #else
    public static let validDomains: [SocketDomain] = [SocketDomain(rawValue: PF_UNIX), .local]
    #endif

    public static let defaultDomain: SocketDomain = .local

    // swiftlint:disable identifier_name
    #if os(Linux)
    public static let PATH_MAX = 108
    #else
    public static let PATH_MAX = 104
    #endif
    // swiftlint:enable identifier_name

    public var domain: SocketDomain
    public let address: FilePath

    public init(address: FilePath) {
        self.address = address
        self.domain = LocalAddress.defaultDomain
    }

    public func convertToConnectableAddress() throws -> (SocketAddress, SocketAddressSize) {
        guard address.string.count < LocalAddress.PATH_MAX else {
            throw LocalAddressError.pathnameTooLong
        }

        var addr = LocalSocketAddress()

        let strlen = MemoryLayout.size(ofValue: addr.sun_path)
        withUnsafeMutablePointer(to: &addr.sun_path) {
            $0.withMemoryRebound(to: Int8.self, capacity: strlen) {
                _ = strncpy($0, address.string, strlen)
            }
        }

        return (unsafeBitCast(addr, to: SocketAddress.self), SocketAddressSize(MemoryLayout.size(ofValue: addr)))
    }
}

public typealias UnixAddress = LocalAddress
