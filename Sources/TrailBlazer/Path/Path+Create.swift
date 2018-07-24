#if os(Linux)
import Glibc
let cUmask = Glibc.umask
#else
import Darwin
let cUmask = Darwin.umask
#endif

public protocol Creatable: Openable {
    associatedtype CreatablePathType: Path & Openable
    @discardableResult
    func create(mode: FileMode, ignoreUMask: Bool) throws -> Open<CreatablePathType>
}

public typealias UMask = FileMode
private var _umask: UMask = getInitialUMask()
public private(set) var lastUMask: UMask = _umask
public var umask: UMask {
    get { return _umask }
    set { setUMask(for: newValue) }
}

private func getInitialUMask() -> UMask {
    // Setting the mask returns the original mask
    let mask = FileMode(rawValue: cUmask(FileMode.allPermissions.rawValue))

    // Reset the mask back to it's original value
    defer { let _ = cUmask(mask.rawValue) }

    return mask
}

@discardableResult
public func setUMask(for mode: FileMode) -> UMask {
    lastUMask = FileMode(rawValue: cUmask(mode.rawValue))
    _umask = mode
    _umask.bits = .none
    return _umask
}

public func resetUMask() {
    umask = lastUMask
}

extension FilePath: Creatable {
    public typealias CreatablePathType = FilePath

    @discardableResult
    public func create(mode: FileMode, ignoreUMask: Bool = false) throws -> Open<FilePath> {
        if ignoreUMask {
            setUMask(for: mode)
        }
        defer {
            if ignoreUMask {
                resetUMask()
            }
        }

        return try open(permissions: .write, flags: .create, .excl, mode: mode)
    }
}

extension DirectoryPath: Creatable {
    public typealias CreatablePathType = DirectoryPath

    @discardableResult
    public func create(mode: FileMode, ignoreUMask: Bool = false) throws -> Open<DirectoryPath> {
        if ignoreUMask {
            setUMask(for: mode)
        }
        defer {
            if ignoreUMask {
                resetUMask()
            }
        }

        guard mkdir(string, mode.rawValue) != -1 else {
            throw CreateDirectoryError.getError()
        }

        return try self.open(mode: mode)
    }
}

extension Open: Creatable where PathType: Creatable {
    public typealias CreatablePathType = PathType.CreatablePathType

    @discardableResult
    public func create(mode: FileMode, ignoreUMask: Bool = false) throws -> Open<CreatablePathType> {
        return try _path.create(mode: mode, ignoreUMask: ignoreUMask)
    }
}
