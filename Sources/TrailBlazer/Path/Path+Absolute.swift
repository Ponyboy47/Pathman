import ErrNo

#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Path {
    /// The full canonicalized path. Will only be nil if the calling process
    /// does not have access to the path or if a system error occurs
    public var absolute: Self! {
        return try! self.expand()
    }

    /// Whether or not the current path is absolute
    public var isAbsolute: Bool {
        return !isRelative
    }

    /**
    Expands all symbolic links and resolves references to ~/, /./, /../ and extra
    '/' characters to produce a canonicalized absolute pathname.

    - Throws:
        - RealSelfError.permissionDenied: Read or search permission was denied for a component of the path prefix.
        - RealSelfError.emptySelf: (Shouldn't ever occur) path is NULL.
        - RealSelfError.ioError: An I/O error occurred while reading from the filesystem.
        - RealSelfError.tooManySymlinks: Too many symbolic links were encountered in translating the pathname.
        - RealSelfError.pathnameTooLong: (Shouldn't ever occur) A component of a pathname exceeded NAME_MAX characters, or an entire pathname exceeded PATH_MAX characters.
        - RealSelfError.outOfMemory: Out of memory.
        - RealSelfError.pathDoesNotExist: The named file does not exist.
        - RealSelfError.notADirectory: A component of the path prefix is not a directory.
    */
    public func expand() throws -> Self {
        // If the path is already absolute, then there's no point in calling realpath(3)
        guard isRelative else { return self }

        // realpath(3) fails if the path is null
        guard !_path.isEmpty else { return self }

        var str = _path

        if str.hasPrefix("~") {
            let home = try Self.getHome()
            str = str.replacingOccurrences(of: "^~", with: home.string, options: .regularExpression)
        }

        // realpath(3) fails if the path is longer than PATH_MAX characters
        guard str.count < PATH_MAX else { return self }

        // realpath(3) fails if any of the path components are longer than NAME_MAX characters
        guard str.components(separatedBy: Self.separator).reduce(true, { $0 ? $1.count <= NAME_MAX : false }) else { return self }

        // realpath(3) fails if the path does not exist
        guard Self(str)!.exists else { return Self(str)! }

        guard let realpath = realpath(str, nil) else { throw RealPathError.getError() }

        return Self(String(cString: realpath))!
    }
}
