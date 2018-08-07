import Cglob

/// The C globbing function
let cGlob = Cglob.glob
/// The C function for freeing a glob struct
public let cGlobFree = Cglob.globfree

/// A reusable Glob struct
private var globalGlob = Glob()

/** Locates all paths matching the pattern specified

    - Parameter pattern: The path string and glob pattern to use for finding paths
    - Parameter flags: Glob flags to customize the globbing behavior (see GlobFlags)
    - Parameter errorClosure: A closure used if a path in the glob causes an error. Returning a nonZero integer will cause the glob function to throw an error
    - Returns: A Glob object that contains the paths matching the pattern as well as other information about the glob

    - Throws: `GlobError.outOfMemory` when there is not enough space to store the results in the glob object
    - Throws: `GlobError.readError` when an error occurred while reading a directory
    - Throws: `GlobError.noMatches` when there were no matches found. Using the `.noCheck` flag will prevent this error from being thrown.
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
*/
public func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil) throws -> Glob {
    try glob(pattern: pattern, flags: flags, errorClosure: errorClosure, glob: &globalGlob)
    return globalGlob
}

/** Locates all paths matching the pattern specified

    - Parameter pattern: The path string and glob pattern to use for finding paths
    - Parameter flags: Glob flags to customize the globbing behavior (see GlobFlags)
    - Parameter errorClosure: A closure used if a path in the glob causes an error. Returning a nonZero integer will cause the glob function to throw an error
    - Parameter glob: The glob object into which the glob results are stored

    - Throws: `GlobError.outOfMemory` when there is not enough space to store the results in the glob object
    - Throws: `GlobError.readError` when an error occurred while reading a directory
    - Throws: `GlobError.noMatches` when there were no matches found. Using the `.noCheck` flag will prevent this error from being thrown.
    - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
    - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
    - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
    - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
    - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
    - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
*/
public func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil, glob: inout Glob) throws {
    let globResult = cGlob(pattern, flags.rawValue, errorClosure, glob._glob)
    guard globResult == 0 else {
        do {
            throw GlobError.getError(globResult)
        // There may be an error thrown from the underlying opendir/malloc
        // calls, so if it's an unknown GlobError try throwing the
        // OpenDirectoryError (malloc errors hopefully won't ever happen)
        } catch GlobError.unknown {
            throw OpenDirectoryError.getError()
        }
    }
}

extension DirectoryPath {
    /** Locates all paths matching the pattern specified using this DirectoryPath as the base directory for the glob

        - Parameter pattern: The glob pattern to use for finding paths
        - Parameter flags: Glob flags to customize the globbing behavior (see GlobFlags)
        - Parameter errorClosure: A closure used if a path in the glob causes an error. Returning a nonZero integer will cause the glob function to throw an error
        - Returns: A Glob object that contains the paths matching the pattern as well as other information about the glob

        - Throws: `GlobError.outOfMemory` when there is not enough space to store the results in the glob object
        - Throws: `GlobError.readError` when an error occurred while reading a directory
        - Throws: `GlobError.noMatches` when there were no matches found. Using the `.noCheck` flag will prevent this error from being thrown.
        - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
        - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
        - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
        - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
        - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
        - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil) throws -> Glob {
        return try TrailBlazer.glob(pattern: (self + pattern).string, flags: flags, errorClosure: errorClosure)
    }

    /** Locates all paths matching the pattern specified using this DirectoryPath as the base directory for the glob

        - Parameter pattern: The glob pattern to use for finding paths
        - Parameter flags: Glob flags to customize the globbing behavior (see GlobFlags)
        - Parameter errorClosure: A closure used if a path in the glob causes an error. Returning a nonZero integer will cause the glob function to throw an error
        - Parameter glob: The glob object into which the glob results are stored

        - Throws: `GlobError.outOfMemory` when there is not enough space to store the results in the glob object
        - Throws: `GlobError.readError` when an error occurred while reading a directory
        - Throws: `GlobError.noMatches` when there were no matches found. Using the `.noCheck` flag will prevent this error from being thrown.
        - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
        - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
        - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
        - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
        - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
        - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This should only occur if your DirectoryPath object was created before the path existed and then the path was created as a non-directory path type
    */
    public func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil, glob: inout Glob) throws {
        try TrailBlazer.glob(pattern: (self + pattern).string, flags: flags, errorClosure: errorClosure, glob: &glob)
    }
}

/// The construct used and returned by globbing
public class Glob {
    /// A pointer to the underlying glob_t struct used for the C glob(3) API calls
    fileprivate var _glob: UnsafeMutablePointer<glob_t>
    /// Whether or not this library owns the underlying glob_t struct and can
    /// safely free it's memory on deinitialization
    private let owned: Bool

    /// The number of matches that should be found in the matches collection
    public var trueCount: Int { return Int(count - offset) }
    /// The number of matches + the offset
    public var count: UInt { return _glob.pointee.gl_pathc }
    /** The paths that matched the globbing pattern

        NOTE: Since this is a computed variable, it would be more efficient to
        store this into a variable for use in your program if you intend to use
        it more than once. (Getting the files and then getting the directories
        constitutes multiple accesses and therefore multiple computations)
    */
    public var matches: PathCollection {
        // Create the children collection
        let children = PathCollection()

        // Array of Strings of the matched paths. (char **)
        var item = _glob.pointee.gl_pathv

        // Skip the offset number of matches since those are reserved and will be nil
        for _ in 0..<offset {
            item = item?.successor()
        }

        // Go through the remaining items, get the path type, and append it to
        // the relevant children array
        for _ in offset...count {
            // Make sure the item pointed to is not nil or else we've hit the
            // end. The glob(3) docs say the array is null-terminated.
            guard let pointee = item?.pointee else { break }

            // Cast the char * pointee to a swift String
            let path = String(cString: pointee)

            // Get the path type and append it to the corresponding array
            if let file = FilePath(path) {
                children.files.append(file)
            } else if let dir = DirectoryPath(path) {
                children.directories.append(dir)
            } else {
                children.other.append(GenericPath(path))
            }

            // Advance to the next item in the array
            item = item?.successor()
        }

        return children
    }
    /** The number of reserved items at the beginning of the matches in the
        underlying glob_t struct. Reserved items are ignored/skipped in the
        matches variable of this Glob object.
    */
    public var offset: UInt { return _glob.pointee.gl_offs }
    /// The C function to use to close directories (default is closedir(2))
    public var closedir: (@convention(c) (UnsafeMutableRawPointer?) -> ()) {
        get { return _glob.pointee.gl_closedir }
        set {
            _glob.pointee.gl_closedir = newValue
        }
    }
    /// The C function used to read directories (default is readdir(2))
    public var readdir: (@convention(c) (UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?) {
        get { return _glob.pointee.gl_readdir }
        set {
            _glob.pointee.gl_readdir = newValue
        }
    }
    /// The C function used to open directories (default is opendir(2))
    public var opendir: (@convention(c) (UnsafePointer<CChar>?) -> UnsafeMutableRawPointer?) {
        get { return _glob.pointee.gl_opendir }
        set {
            _glob.pointee.gl_opendir = newValue
        }
    }
    /// The C function used to lstat directories (default is lstat(2))
    public var lstat: (@convention(c) (UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> FileDescriptor) {
        get { return _glob.pointee.gl_lstat }
        set {
            _glob.pointee.gl_lstat = newValue
        }
    }
    /// The C function used to stat directories (default is stat(2))
    public var stat: (@convention(c) (UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> FileDescriptor) {
        get { return _glob.pointee.gl_stat }
        set {
            _glob.pointee.gl_stat = newValue
        }
    }
    /// The flags used by the glob (if it was previously used before)
    public var flags: GlobFlags { return GlobFlags(rawValue: _glob.pointee.gl_flags) }

    /// Initializes with an empty glob_t struct
    public init() {
        _glob = UnsafeMutablePointer.allocate(capacity: 1)
        _glob.initialize(to: glob_t())

        // Since we have sole control over the pointer, it's safe to deallocate
        // it at deinitialization
        owned = true
    }

    /** Initializes with a pointer to the specified glob_t struct. Only use
        this initializer if you have a specific reason to own the management of
        your glob_t struct. You MUST call globfree(3) (or cGlobFree) with your
        glob_t struct when you are done or it will be a memory leak
    */
    public init(glob: UnsafeMutablePointer<glob_t>) {
        _glob = glob

        // If the user is passing their own glob_t pointer, then we do not own
        // the management of it and they will have to free it themselves
        owned = false
    }

    // When this object is deconstructed, be sure to free the glob pointer (or
    // you'll have a memory leak)
    deinit {
        if owned {
            cGlobFree(_glob)
        }
    }
}
