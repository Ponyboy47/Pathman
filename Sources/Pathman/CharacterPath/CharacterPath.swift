/// A Path to a file
public struct CharacterPath: Path {
    public static let pathType: PathType = .character
    public static var defaultByteCount: ByteRepresentable = Int.max

    // swiftlint:disable identifier_name
    public var _path: String

    public let _info: StatInfo
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

    @available(*, unavailable, message: "Cannot append to a CharacterPath")
    public static func + <PathType: Path>(_: CharacterPath, _: PathType) -> PathType {
        fatalError("Cannot append to a CharacterPath")
    }
}
