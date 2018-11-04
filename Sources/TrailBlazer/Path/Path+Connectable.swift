#if os(Linux)
import func Glibc.inet_pton
import struct Glibc.sockaddr
import struct Glibc.sockaddr_in
import struct Glibc.sockaddr_in6
import struct Glibc.sockaddr_un
import typealias Glibc.socklen_t
import func Glibc.strncpy
#else
import func Darwin.inet_pton
import struct Darwin.sockaddr
import struct Darwin.sockaddr_in
import struct Darwin.sockaddr_in6
import struct Darwin.sockaddr_un
import typealias Darwin.socklen_t
import func Darwin.strncpy
#endif

public typealias SocketAddress = sockaddr
public typealias SocketAddressSize = socklen_t

public protocol Connectable: Openable where OpenOptionsType: SocketOption {
    typealias ConnectionOptionsType = OpenOptionsType

    func connect<AddressType: Address>(options: ConnectionOptionsType,
                                       type: ConnectionType,
                                       address: AddressType) throws -> Connection<Self>
    static func shutdown(connected: Connection<Self>) throws
}

public enum ConnectionType {
    case client
    case server
}

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

public protocol PortSpecificAddress: DomainRestrictedAddress {
    var port: OptionInt { get }
    static var defaultPort: OptionInt { get }

    init(address: AddressType, port: OptionInt)
}

extension PortSpecificAddress {
    public static var defaultPort: OptionInt {
        return OptionInt.random(in: 1025 ... .max)
    }

    public init(address: AddressType) {
        self.init(address: address, port: Self.defaultPort)
    }

    public init(domain: SocketDomain, address: AddressType, port: OptionInt) throws {
        guard Self.validDomains.contains(domain) else { throw AddressError.invalidDomain }

        self.init(address: address, port: port)
        self.domain = domain
    }
}

public struct IPAddress: PortSpecificAddress {
    public static let validDomains: [SocketDomain] = [.ipv4, .ipv6]
    public static let defaultDomain: SocketDomain = .ipv4

    public var domain: SocketDomain
    public let address: String
    public let port: OptionInt

    public init(address: String, port: OptionInt) {
        self.address = address
        self.port = port
        self.domain = IPAddress.defaultDomain
    }

    public func convertToConnectableAddress() throws -> (SocketAddress, SocketAddressSize) {
        let addr: SocketAddress
        let addrSize: Int

        switch domain {
        case .ipv4:
            var ipv4Info = sockaddr_in()
            guard inet_pton(domain.rawValue, address, &ipv4Info.sin_addr) == 1 else {
                // The only possible errors are invalidAddressString and
                // unsupportedAddressFamily, this struct should limit it to just
                // invalidAddressString
                throw IPAddressError.invalidAddressString
            }
            addr = unsafeBitCast(ipv4Info, to: SocketAddress.self)
            addrSize = MemoryLayout.size(ofValue: ipv4Info)
        case .ipv6:
            var ipv6Info = sockaddr_in6()
            guard inet_pton(domain.rawValue, address, &ipv6Info.sin6_addr) == 1 else {
                // The only possible errors are invalidAddressString and
                // unsupportedAddressFamily, this struct should limit it to just
                // invalidAddressString
                throw IPAddressError.invalidAddressString
            }
            addr = unsafeBitCast(ipv6Info, to: SocketAddress.self)
            addrSize = MemoryLayout.size(ofValue: ipv6Info)
        default: fatalError("Invalid domain")
        }

        return (addr, SocketAddressSize(addrSize))
    }
}

public struct LocalAddress: DomainRestrictedAddress {
    public static let validDomains: [SocketDomain] = [.unix, .local]
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

        var addr = sockaddr_un()

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
