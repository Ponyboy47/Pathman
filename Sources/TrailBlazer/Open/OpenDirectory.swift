#if os(Linux)
import Glibc
#else
import Darwin
#endif

public typealias OpenDirectory = Open<DirectoryPath>

extension Open: Sequence, IteratorProtocol where PathType: DirectoryPath {
    public typealias Element = GenericPath

    public func children(includeHidden: Bool = false) -> PathCollection {
        // Since the directory is already opened, getting the immediate
        // children is always safe
        return try! _path.children(includeHidden: includeHidden)
    }

    public func recursiveChildren(depth: Int = -1, includeHidden: Bool = false) throws -> PathCollection {
        return try _path.recursiveChildren(depth: depth, includeHidden: includeHidden)
    }

    public func next() -> GenericPath? {
        return _path.next()
    }
}

public extension Open where PathType: DirectoryPath {
    public func changeRecursive(owner uid: uid_t = ~0, group gid: gid_t = ~0) throws {
        try change(owner: uid, group: gid)

        for path in self {
            if let dir = DirectoryPath(path) {
                guard !["..", "."].contains(dir.lastComponent) else { continue }
                try dir.changeRecursive(owner: uid, group: gid)
            } else {
                try path.change(owner: uid, group: gid)
            }
        }
    }

    public func changeRecursive(owner username: String? = nil, group groupname: String? = nil) throws {
        let uid: uid_t
        let gid: gid_t

        if let username = username {
            uid = try getUserInfo(username).pw_uid
        } else {
            uid = ~0
        }

        if let groupname = groupname {
            gid = try getGroupInfo(groupname).gr_gid
        } else {
            gid = ~0
        }

        try changeRecursive(owner: uid, group: gid)
    }

    public func changeRecursive(permissions: FileMode) throws {
        try change(permissions: permissions)

        for path in self {
            if let dir = DirectoryPath(path) {
                guard !["..", "."].contains(dir.lastComponent) else { continue }
                try dir.changeRecursive(permissions: permissions)
            } else {
                try path.change(permissions: permissions)
            }
        }
    }

    public func changeRecursive(owner: FilePermissions, group: FilePermissions, others: FilePermissions, bits: FileBits) throws {
        try changeRecursive(permissions: FileMode(owner: owner, group: group, others: others, bits: bits))
    }

    public func changeRecursive(owner: FilePermissions? = nil, group: FilePermissions? = nil, others: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try changeRecursive(owner: owner ?? current.owner, group: group ?? current.group, others: others ?? current.others, bits: bits ?? current.bits)
    }

    public func changeRecursive(ownerGroup perms: FilePermissions, others: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try changeRecursive(owner: perms, group: perms, others: current.others, bits: bits ?? current.bits)
    }

    public func changeRecursive(ownerOthers perms: FilePermissions, group: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try changeRecursive(owner: perms, group: group ?? current.group, others: perms, bits: bits ?? current.bits)
    }

    public func changeRecursive(groupOthers perms: FilePermissions, owner: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try changeRecursive(owner: owner ?? current.owner, group: perms, others: perms, bits: bits ?? current.bits)
    }

    public func changeRecursive(ownerGroupOthers perms: FilePermissions, bits: FileBits? = nil) throws {
        try changeRecursive(owner: perms, group: perms, others: perms, bits: bits ?? permissions.bits)
    }
}
