#if os(Linux)
import Glibc
/// The C function for setting a process's umask
let cUmask = Glibc.umask
#else
import Darwin
/// The C function for setting a process's umask
let cUmask = Darwin.umask
#endif

/**
A UMask is basically just a FileMode, only the permissions contained in it are
actually the permissions to be rejected when creating paths
*/
public typealias UMask = FileMode

/// The process's current umask
private var _umask: UMask = originalUMask

/// The process's original umask
public var originalUMask: UMask = {
    // Setting the mask returns the original mask
    let mask = FileMode(rawValue: cUmask(FileMode.allPermissions.rawValue))

    // Reset the mask back to it's original value
    defer { let _ = cUmask(mask.rawValue) }

    return mask
}()

/// The process's last umask
public private(set) var lastUMask: UMask = _umask

/// The process's curent umask
public var umask: UMask {
    get { return _umask }
    set { setUMask(for: newValue) }
}

/**
Sets the process's umask and then returns it

- Parameter mode: The permissions that should be set in the mask
- Returns: The new umask
*/
@discardableResult
public func setUMask(for mode: FileMode) -> UMask {
    lastUMask = FileMode(rawValue: cUmask(mode.rawValue))
    _umask = mode
    _umask.bits = .none
    return _umask
}

/// Changes the umask back to its original umask
public func resetUMask() {
    umask = originalUMask
}

