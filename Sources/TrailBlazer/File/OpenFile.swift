public typealias OpenFile = Open<FilePath>

public extension Open where PathType == FilePath {
    /// Whether or not the path was opened with read permissions
    var mayRead: Bool { return openPermissions.mayRead }

    /// Whether or not the path was opened with write permissions
    var mayWrite: Bool { return openPermissions.mayWrite }

    var openPermissions: OpenFilePermissions { return openOptions.permissions }
    var openFlags: OpenFileFlags { return openOptions.flags }
    var createMode: FileMode? { return openOptions.mode }
}
