#if os(Linux)
import func Glibc.realpath
#else
import func Darwin.realpath
#endif
let cRealpath = realpath

public extension Path {
    /// The full canonicalized path
    var absolute: Self? {
        return try? self.expanded()
    }

    /// Whether or not the current path is absolute
    var isAbsolute: Bool {
        return !isRelative
    }

    /**
    Mutates self and expands all symbolic links and resolves references to ~/, /./, /../ and extra
    '/' characters to produce a canonicalized absolute pathname.

    - Throws:
        - RealPathError.permissionDenied: Read or search permission was denied for a component of the path prefix.
        - RealPathError.emptyPath: path is NULL (AKA empty).
        - RealPathError.ioError: An I/O error occurred while reading from the filesystem.
        - RealPathError.tooManySymlinks: Too many symbolic links were encountered in translating the pathname.
        - RealPathError.pathnameTooLong: The entire pathname exceeded PATH_MAX characters.
        - RealPathError.pathComponentTooLong: A component of a pathname exceeded NAME_MAX characters
        - RealPathError.outOfMemory: Out of memory.
        - RealPathError.pathDoesNotExist: The named file does not exist.
        - RealPathError.notADirectory: A component of the path prefix is not a directory.
    */
    mutating func expand() throws {
        // realpath(3) fails if the path is null
        guard !_path.isEmpty else { return }

        _path = _path.replacingOccurrences(of: "\(Self.separator)\(Self.separator)", with: "\(Self.separator)")

        // If the path is already absolute, then there's no point in calling realpath(3)
        guard isRelative else { return }

        // Whenever we leave this function we need to update the path used by StatInfo
        defer { _info._path = _path }

        if _path.hasPrefix("~") {
            let home = try getHome()
            _path.replaceSubrange(..<_path.index(after: _path.startIndex), with: home.string)
        }

        // If the path is absolute after expanding the home directory, then no need to call into realpath(3)
        guard isRelative else { return }

        let realpath = try cRealpath(_path, nil) ?! RealPathError.getError()

        _path = String(cString: realpath)

        // When realpath(3) is passed a nil buffer argument, the memory is
        // dynamically allocated and must be deallocated
        realpath.deinitialize(count: 1)
        realpath.deallocate()
    }

    /**
    Expands all symbolic links and resolves references to ~/, /./, /../ and extra
    '/' characters to produce a canonicalized absolute pathname.

    - Returns: The expanded copy of self
    - Throws:
        - RealPathError.permissionDenied: Read or search permission was denied for a component of the path prefix.
        - RealPathError.emptyPath: path is NULL (AKA empty).
        - RealPathError.ioError: An I/O error occurred while reading from the filesystem.
        - RealPathError.tooManySymlinks: Too many symbolic links were encountered in translating the pathname.
        - RealPathError.pathnameTooLong: The entire pathname exceeded PATH_MAX characters.
        - RealPathError.pathComponentTooLong: A component of a pathname exceeded NAME_MAX characters
        - RealPathError.outOfMemory: Out of memory.
        - RealPathError.pathDoesNotExist: The named file does not exist.
        - RealPathError.notADirectory: A component of the path prefix is not a directory.
    */
    func expanded() throws -> Self {
        var toExpand = Self(_path) !! "The path '\(_path)' is not a \(Self.self)"
        try toExpand.expand()
        return toExpand
    }
}
