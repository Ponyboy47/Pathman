/// A Path to a directory
public struct DirectoryPath: Path {
    public static let pathType: PathType = .directory

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
        guard DirectoryPath.validatePathType(path) else { return nil }

        _path = path._path
        _info = StatInfo(path)
        try? _info.getInfo()
    }

    /**
     Appends a String to a DirectoryPath

     - Parameter lhs: The DirectoryPath to append to
     - Parameter rhs: The String to append

     - Returns: A GenericPath which is the combination of the lhs + Path.separator + rhs
     */
    public static func + (lhs: DirectoryPath, rhs: String) -> GenericPath {
        return lhs + GenericPath(rhs)
    }

    /**
     Appends a Path to a DirectoryPath

     - Parameter lhs: The DirectoryPath to append to
     - Parameter rhs: The Path to append

     - Returns: A PathType which is the combination of the lhs + Path.separator + rhs
     */
    public static func + <PathType: Path>(lhs: DirectoryPath, rhs: PathType) -> PathType {
        var newPath = lhs.string
        let right = rhs.string

        if !newPath.hasSuffix(DirectoryPath.separator) {
            newPath += DirectoryPath.separator
        }

        if right.hasPrefix(DirectoryPath.separator) {
            newPath += right.dropFirst()
        } else {
            newPath += right
        }

        return PathType(newPath) !! "Failed to initialize \(PathType.self) from \(Swift.type(of: newPath)) '\(newPath)'"
    }

    /**
     Append a DirectoryPath to another

     - Parameter lhs: The DirectoryPath to modify
     - Parameter rhs: The DirectoryPath to append
     */
    public static func += (lhs: inout DirectoryPath, rhs: DirectoryPath) {
        // swiftlint:disable shorthand_operator
        lhs = lhs + rhs
        // swiftlint:enable shorthand_operator
    }

    // swiftlint:disable line_length
    @available(*, unavailable, message: "Appending FilePath to DirectoryPath results in a FilePath, but it is impossible to change the type of the left-hand object from a DirectoryPath to a FilePath")
    public static func += (_: inout DirectoryPath, _: FilePath) {}
    // swiftlint:enable line_length
}
