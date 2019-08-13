#if os(Linux)
import func Glibc.umask
/// The C function for setting a process's umask
private let cUmask = Glibc.umask
#else
import func Darwin.umask
/// The C function for setting a process's umask
private let cUmask = Darwin.umask
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
    defer { _ = cUmask(mask.rawValue) }

    return mask
}()

/// The process's last umask
public private(set) var lastUMask: UMask = _umask

/// The process's curent umask, which are the permissions that will be rejected when creating new paths
public var umask: UMask {
    get { return _umask }
    set { setUMask(for: newValue) }
}

/**
 Sets the process's umask and then returns it

 - Parameter mode: The permissions that should be allowed in the mask
 - Returns: The new umask
 */
@discardableResult
public func setUMask(for mode: FileMode) -> UMask {
    var newUMask = ~mode

    // umask(2) on Linux always &'s the umask with 0o0777 which ignores the
    // FileBits. Apparently macOS does not do this though
    #if os(Linux)
    newUMask &= .allPermissions
    #endif

    // Invert the mode and use that as the umask
    lastUMask = FileMode(rawValue: cUmask(newUMask.rawValue))
    _umask = newUMask

    return _umask
}

/// Changes the umask back to its original umask
public func resetUMask() {
    umask = ~originalUMask
}
