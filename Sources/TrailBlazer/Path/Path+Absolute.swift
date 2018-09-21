#if os(Linux)
import Glibc
let cRealpath = Glibc.realpath
#else
import Darwin
let cRealpath = Darwin.realpath
#endif

extension Path {
    /// The full canonicalized path
    public var absolute: Self? {
        return try? self.expanded()
    }

    /// Whether or not the current path is absolute
    public var isAbsolute: Bool {
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
    public mutating func expand() throws {
        // If the path is already absolute, then there's no point in calling realpath(3)
        guard isRelative else { return }

        // realpath(3) fails if the path is null
        guard !_path.isEmpty else { throw RealPathError.emptyPath }

        if _path.hasPrefix("~") {
            let home = try getHome()
            _path.replaceSubrange(..<_path.index(after: _path.startIndex), with: home.string)
        }

        let realpath = try cRealpath(_path, nil) ?! RealPathError.getError()

        // When realpath(3) is passed a nil buffer argument, the memory is
        // dynamically allocated and must be deallocated
        defer { realpath.deallocate() }

        _path = String(cString: realpath)
        info._path = _path
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
    public func expanded() throws -> Self {
        // If the path is already absolute, then there's no point in calling realpath(3)
        guard isRelative else { return self }

        // realpath(3) fails if the path is null
        guard !_path.isEmpty else { throw RealPathError.emptyPath }

        var str = _path

        if str.hasPrefix("~") {
            let home = try getHome()
            str.replaceSubrange(..<str.index(after: str.startIndex), with: home.string)
        }

        let realpath = try cRealpath(str, nil) ?! RealPathError.getError()

        // When realpath(3) is passed a nil buffer argument, the memory is
        // dynamically allocated and must be deallocated
        defer { realpath.deallocate() }

        let realpathString = String(cString: realpath)
        return Self(realpathString) !! "In the time since this \(Self.self) object was created, a path of a different type has been created at the same location (\(realpathString))."
    }
}
