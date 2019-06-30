/// Protocol declaration for types that can be opened
public protocol Openable: Path {
    associatedtype OpenOptionsType: OpenOptionable = Empty
    associatedtype DescriptorType: Descriptor

    /// Opens the path, sets the `fileDescriptor`, and returns the newly opened path
    func open(options: OpenOptionsType) throws -> Open<Self>
    /// Closes the opened `fileDescriptor` and sets it to nil
    static func close(opened: Open<Self>) throws
}

public struct Empty: OpenOptionable {
    public static let `default` = Empty()
    public init() {}
}

public extension Openable {
    func open(options: OpenOptionsType, closure: (_ opened: Open<Self>) throws -> Void) throws {
        let opened = try open(options: options)
        try closure(opened)
        try opened.close()
    }
}

public extension Openable where OpenOptionsType == Empty {
    func open() throws -> Open<Self> {
        return try open(options: .default)
    }

    func open(closure: (_ opened: Open<Self>) throws -> Void) throws {
        let opened = try open()
        try closure(opened)
        try opened.close()
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
