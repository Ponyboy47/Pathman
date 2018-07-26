import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol StatDelegate {
    var info: StatInfo { get }
}

public extension StatDelegate {
    public var id: dev_t {
        return info.id
    }
    public var inode: ino_t {
        return info.inode
    }
    public var type: FileType? {
        return info.type
    }
    public var permissions: FileMode {
        return info.permissions
    }
    public var owner: uid_t {
        return info.owner
    }
    public var group: gid_t {
        return info.group
    }
    public var device: dev_t {
        return info.device
    }
    public var size: OSInt {
        return OSInt(info.size)
    }
    public var blockSize: OSInt {
        return OSInt(info.blockSize)
    }
    public var blocks: OSInt {
        return OSInt(info.blocks)
    }

    public var lastAccess: Date {
        return info.lastAccess
    }
    public var lastModified: Date {
        return info.lastModified
    }
    public var lastAttributeChange: Date {
        return info.lastAttributeChange
    }
    #if os(macOS)
    public var creation: Date {
        return info.creation
    }
    #endif
}
