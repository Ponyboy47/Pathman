import Cglob

/// The construct used and returned by globbing
public final class Glob {
    /// A pointer to the underlying glob_t struct used for the C glob(3) API calls
    var _glob: UnsafeMutablePointer<glob_t>
    /// Whether or not this library owns the underlying glob_t struct and can
    /// safely free it's memory on deinitialization
    private let owned: Bool

    /// The number of matches that should be found in the matches collection
    public var trueCount: Int { return Int(count - offset) }
    /// The number of matches + the offset
    public var count: Int { return Int(_glob.pointee.gl_pathc) }
    /** The paths that matched the globbing pattern

        NOTE: Since this is a computed variable, it would be more efficient to
        store this into a variable for use in your program if you intend to use
        it more than once. (Getting the files and then getting the directories
        constitutes multiple accesses and therefore multiple computations)
    */
    public var matches: PathCollection {
        // Create the children collection
        var children = PathCollection()

        // Array of Strings of the matched paths. (char **)
        var item = _glob.pointee.gl_pathv

        // Skip the offset number of matches since those are reserved and will be nil
        for _ in 0..<offset {
            item = item?.successor()
        }

        // Make sure the item pointed to is not nil or else we've hit the
        // end. The glob(3) docs say the array is null-terminated.
        while let pointee = item?.pointee {
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
    public var offset: Int { return Int(_glob.pointee.gl_offs) }

    #if os(macOS)
    /** The limit on the number of matches to return. Intended to prevent DoS
      attacks. Only honored if the .limit GlobFlag is included.
    */
    public var limit: Int {
        get { return Int(_glob.pointee.gl_matchc) }
        set { _glob.pointee.gl_matchc = OptionInt(newValue) }
    }
    #endif

    /// The C function to use to close directories (default is closedir(2))
    public var closedir: (@convention(c) (UnsafeMutableRawPointer?) -> ()) {
        get { return _glob.pointee.gl_closedir }
        set {
            _glob.pointee.gl_closedir = newValue
        }
    }

    #if os(Linux)
    public typealias GlobReadDirectoryReturnType = UnsafeMutableRawPointer
    #else
    public typealias GlobReadDirectoryReturnType = UnsafeMutablePointer<dirent>
    #endif
    /// The C function used to read directories (default is readdir(2))
    public var readdir: (@convention(c) (UnsafeMutableRawPointer?) -> GlobReadDirectoryReturnType?) {
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

    #if os(Linux)
    public typealias GlobStatType = UnsafeMutableRawPointer
    #else
    public typealias GlobStatType = UnsafeMutablePointer<stat>
    #endif
    /// The C function used to lstat directories (default is lstat(2))
    public var lstat: (@convention(c) (UnsafePointer<CChar>?, GlobStatType?) -> FileDescriptor) {
        get { return _glob.pointee.gl_lstat }
        set {
            _glob.pointee.gl_lstat = newValue
        }
    }
    /// The C function used to stat directories (default is stat(2))
    public var stat: (@convention(c) (UnsafePointer<CChar>?, GlobStatType?) -> FileDescriptor) {
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
