public typealias CharacterStream = Open<CharacterPath>

public extension Open where PathType == CharacterPath {
    /// Whether or not the path was opened with read permissions
    var mayRead: Bool { return openMode.mayRead }

    /// Whether or not the path was opened with write permissions
    var mayWrite: Bool { return openMode.mayWrite }

    var openMode: OpenFileMode { return openOptions.mode }
}
