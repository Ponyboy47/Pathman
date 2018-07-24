import Cglob
let cGlob = Cglob.glob
let cGlobFree = Cglob.globfree

private var globalGlob = Glob()

public func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil) throws -> Glob {
    try glob(pattern: pattern, flags: flags, errorClosure: errorClosure, glob: &globalGlob)
    return globalGlob
}

public func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil, glob: inout Glob) throws {
    let globResult = cGlob(pattern, flags.rawValue, errorClosure, &glob._glob)
    guard globResult == 0 else { throw GlobError.getError(globResult) }
}

extension Path {
    public static func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil) throws -> Glob {
        return try TrailBlazer.glob(pattern: pattern, flags: flags, errorClosure: errorClosure)
    }

    public static func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil, glob: inout Glob) throws {
        try TrailBlazer.glob(pattern: pattern, flags: flags, errorClosure: errorClosure, glob: &glob)
    }
}

extension DirectoryPath {
    public func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil) throws -> Glob {
        return try TrailBlazer.glob(pattern: (self + pattern).string, flags: flags, errorClosure: errorClosure)
    }

    public func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil, glob: inout Glob) throws {
        try TrailBlazer.glob(pattern: (self + pattern).string, flags: flags, errorClosure: errorClosure, glob: &glob)
    }
}

public class Glob {
    fileprivate var _glob: glob_t = glob_t()

    var count: UInt { return _glob.gl_pathc }
    var matches: [String] {
        var matches: [String] = []

        var item = _glob.gl_pathv
        for _ in 0...count {
            guard let pointee = item?.pointee else { break }
            matches.append(String(cString: pointee))
            item = item?.successor()
        }

        return matches
    }
    var offset: UInt { return _glob.gl_offs }
    var closedir: (@convention(c) (UnsafeMutableRawPointer?) -> ()) {
        get { return _glob.gl_closedir }
        set {
            _glob.gl_closedir = newValue
        }
    }
    var readdir: (@convention(c) (UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?) {
        get { return _glob.gl_readdir }
        set {
            _glob.gl_readdir = newValue
        }
    }
    var opendir: (@convention(c) (UnsafePointer<CChar>?) -> UnsafeMutableRawPointer?) {
        get { return _glob.gl_opendir }
        set {
            _glob.gl_opendir = newValue
        }
    }
    var lstat: (@convention(c) (UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> FileDescriptor) {
        get { return _glob.gl_lstat }
        set {
            _glob.gl_lstat = newValue
        }
    }
    var stat: (@convention(c) (UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> FileDescriptor) {
        get { return _glob.gl_stat }
        set {
            _glob.gl_stat = newValue
        }
    }

    public init() {}

    deinit {
        cGlobFree(&_glob)
    }
}
