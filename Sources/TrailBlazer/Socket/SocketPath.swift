public struct SocketPath: Path {
    public static let pathType: PathType = .socket
    public static let emptyReadFlags: ReceiveFlags = .none
    public static let emptyWriteFlags: SendFlags = .none

    // swiftlint:disable identifier_name
    public var _path: String

    public let _info: StatInfo
    // swiftlint:enable identifier_name

    /**
    Initialize from another Path

    - Parameter path: The path to copy
    */
    public init?(_ path: GenericPath) {
        // Cannot initialize a directory from a non-directory type
        if path.exists {
            guard path._info.type == .socket else { return nil }
        }

        _path = path._path
        _info = StatInfo(path)
        try? _info.getInfo()
    }

    @available(*, unavailable, message: "Cannot append to a SocketPath")
    public static func + <PathType: Path>(lhs: SocketPath, rhs: PathType) -> PathType {
        fatalError("Cannot append to a SocketPath")
    }
}
