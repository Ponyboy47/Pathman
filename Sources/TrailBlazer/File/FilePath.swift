/// A Path to a file
public struct FilePath: Path {
    public static let pathType: PathType = .file
    public static var defaultByteCount: ByteRepresentable = Int.max

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
            guard path._info.type == .file else { return nil }
        }

        _path = path._path
        _info = StatInfo(path)
        try? _info.getInfo()
    }

    @available(*, unavailable, message: "Cannot append to a FilePath")
    public static func + <PathType: Path>(_: FilePath, _: PathType) -> PathType {
        fatalError("Cannot append to a FilePath")
    }
}
