import struct Foundation.Date

public extension UpdatableStatable {
    var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    /// Whether or not the path is a directory
    var isDirectory: Bool {
        return _info.exists && _info.type == .directory
    }

    /// Whether or not the path is a file
    var isFile: Bool {
        return _info.exists && _info.type == .file
    }

    /// Whether or not the path is a symlink
    var isLink: Bool {
        try? _info.getInfo(options: .getLinkInfo)
        return _info.exists && _info.type == .link
    }
}

public extension Statable {
    /// Whether or not the path exists (or is accessible)
    var exists: Bool {
        return info.exists
    }

    // swiftlint:disable identifier_name
    /// ID of device containing path
    var id: DeviceID {
        return info.id
    }

    // swiftlint:enable identifier_name
    /// inode number
    var inode: Inode {
        return info.inode
    }

    /// The type of the path
    var type: PathType {
        return info.type
    }

    /// The path permissions
    var permissions: FileMode {
        return info.permissions
    }

    /// user ID of owner
    var owner: UID {
        return info.owner
    }

    /// group ID of owner
    var group: GID {
        return info.group
    }

    /// device ID (if special file)
    var device: DeviceID {
        return info.device
    }

    /// total size, in bytes
    var size: OSOffsetInt {
        return info.size
    }

    /// blocksize for filesystem I/O
    var blockSize: BlockSize {
        return info.blockSize
    }

    /// number of 512B blocks allocated
    var blocks: OSOffsetInt {
        return info.blocks
    }

    /// time of last access
    var lastAccess: Date {
        return info.lastAccess
    }

    /// time of last modification
    var lastModified: Date {
        return info.lastModified
    }

    /// time of last status change
    var lastAttributeChange: Date {
        return info.lastAttributeChange
    }

    #if os(macOS)
    /// time the path was created
    var creation: Date {
        return info.creation
    }
    #endif
}
