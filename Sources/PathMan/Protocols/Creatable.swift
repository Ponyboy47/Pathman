import struct Foundation.Data

public struct CreateOptions: RawRepresentable, OptionSet, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt8
    public let rawValue: IntegerLiteralType

    /// Automatically creating any missing intermediate directories of the path
    public static let createIntermediates = CreateOptions(rawValue: 1 << 0)

    public init(rawValue: IntegerLiteralType) {
        self.init(integerLiteral: rawValue)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        rawValue = value
    }
}

/// A Protocol for Path types that can be created
public protocol Creatable: Openable {
    // swiftlint:disable type_name
    associatedtype _OpenedType = Open<Self>
    // swiftlint:enable type_name
    /**
     Creates a path
     - Parameter mode: The FileMode (permissions) to use for the newly created path
     - Parameter forceMode: Whether or not to try and change the process's umask to guarentee that the FileMode is what
                you want (I've noticed that by default on Ubuntu, others' write access is disabled in the umask. Setting
                this to true should allow you to overcome this limitation)
     */
    @discardableResult
    mutating func create(mode: FileMode?, options: CreateOptions) throws -> _OpenedType
}

public extension Creatable {
    mutating func create(mode: FileMode? = nil,
                         options: CreateOptions = [],
                         closure: (_ opened: _OpenedType) throws -> Void) throws {
        try closure(create(mode: mode, options: options))
    }
}

public extension Creatable where _OpenedType: Writable {
    @discardableResult
    mutating func create(mode: FileMode? = nil,
                         options: CreateOptions = [],
                         contents: Data) throws -> _OpenedType {
        let opened = try create(mode: mode, options: options)
        _ = try opened.write(contents)
        return opened
    }

    @discardableResult
    mutating func create(mode: FileMode? = nil,
                         options: CreateOptions = [],
                         contents: String,
                         using encoding: String.Encoding = .utf8) throws -> _OpenedType {
        let data = try contents.data(using: encoding) ?! StringError.notConvertibleToData(using: encoding)
        return try create(mode: mode, options: options, contents: data)
    }
}
