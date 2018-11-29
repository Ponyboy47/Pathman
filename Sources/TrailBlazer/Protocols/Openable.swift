/// Protocol declaration for types that can be opened
public protocol Openable: Path {
    associatedtype OpenOptionsType: OpenOptionable = Empty
    associatedtype DescriptorType: Descriptor = FileDescriptor

    /// Whether the opened path may be read from
    var mayRead: Bool { get }
    /// Whether the opened path may be written to
    var mayWrite: Bool { get }

    /// Opens the path, sets the `fileDescriptor`, and returns the newly opened path
    func open(options: OpenOptionsType) throws -> Open<Self>
    /// Closes the opened `fileDescriptor` and sets it to nil
    static func close(opened: Open<Self>) throws
}

public struct Empty: OpenOptionable {
    public static let `default` = Empty()
    public init() {}
}

extension Openable {
    public var mayRead: Bool { return true }
    public var mayWrite: Bool { return true }

    public func open(options: OpenOptionsType, closure: (_ opened: Open<Self>) throws -> Void) throws {
        try closure(open(options: options))
    }
}

extension Openable where OpenOptionsType == Empty {
    public func open() throws -> Open<Self> {
        return try open(options: .default)
    }

    public func open(closure: (_ opened: Open<Self>) throws -> Void) throws {
        try closure(open())
    }
}

public protocol OpenOptionable: Hashable {}

public protocol DefaultReadableOpenOption: OpenOptionable {
    static var readableDefault: Self { get }
}

public protocol DefaultWritableOpenOption: OpenOptionable {
    static var writableDefault: Self { get }
}

public typealias DefaultReadableWritableOpenOption = DefaultReadableOpenOption & DefaultWritableOpenOption
