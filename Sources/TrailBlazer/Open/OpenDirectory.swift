#if os(Linux)
import Glibc
#else
import Darwin
#endif

public typealias OpenDirectory = Open<DirectoryPath>

extension Open: Sequence, IteratorProtocol where PathType: DirectoryPath {
    public typealias Element = GenericPath

    public func children(includeHidden: Bool = false) -> DirectoryChildren {
        // Since the directory is already opened, getting the immediate
        // children is always safe
        return try! path.children(includeHidden: includeHidden)
    }

    public func recursiveChildren(depth: Int = -1, includeHidden: Bool = false) throws -> DirectoryChildren {
        return try path.recursiveChildren(depth: depth, includeHidden: includeHidden)
    }

    public func next() -> GenericPath? {
        return path.next()
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
        let uid: uid_t = username != nil ? DirectoryPath.getUserInfo(username!)?.pw_uid ?? ~0 : ~0
        let gid: gid_t = groupname != nil ? DirectoryPath.getGroupInfo(groupname!)?.gr_gid ?? ~0 : ~0

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

    public func changeRecursive(owner: FilePermissions, group: FilePermissions, others: FilePermissions, uid: Bool, gid: Bool, sticky: Bool) throws {
        try changeRecursive(permissions: FileMode(owner: owner, group: group, others: others, uid: uid, gid: gid, sticky: sticky))
    }

    public func changeRecursive(owner perms: FilePermissions...) throws {
        let current = permissions
        try changeRecursive(owner: FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue })), group: current.group, others: current.others, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func changeRecursive(group perms: FilePermissions...) throws {
        let current = permissions
        try changeRecursive(owner: current.owner, group: FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue })), others: current.others, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func changeRecursive(others perms: FilePermissions...) throws {
        let current = permissions
        try changeRecursive(owner: current.owner, group: current.group, others: FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue })), uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func changeRecursive(ownerGroup perms: FilePermissions...) throws {
        let perm = FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue }))
        let current = permissions
        try changeRecursive(owner: perm, group: perm, others: current.others, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func changeRecursive(ownerOthers perms: FilePermissions...) throws {
        let perm = FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue }))
        let current = permissions
        try changeRecursive(owner: perm, group: current.group, others: perm, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func changeRecursive(groupOthers perms: FilePermissions...) throws {
        let perm = FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue }))
        let current = permissions
        try changeRecursive(owner: current.owner, group: perm, others: perm, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func changeRecursive(ownerGroupOthers perms: FilePermissions...) throws {
        let perm = FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue }))
        let current = permissions
        try changeRecursive(owner: perm, group: perm, others: perm, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func changeRecursive(uid: Bool) throws {
        let current = permissions
        try changeRecursive(owner: current.owner, group: current.group, others: current.others, uid: uid, gid: current.gid, sticky: current.sticky)
    }

    public func changeRecursive(gid: Bool) throws {
        let current = permissions
        try changeRecursive(owner: current.owner, group: current.group, others: current.others, uid: current.uid, gid: gid, sticky: current.sticky)
    }

    public func changeRecursive(sticky: Bool) throws {
        let current = permissions
        try changeRecursive(owner: current.owner, group: current.group, others: current.others, uid: current.uid, gid: current.gid, sticky: sticky)
    }

    public func changeRecursive(uid: Bool, gid: Bool) throws {
        let current = permissions
        try changeRecursive(owner: current.owner, group: current.group, others: current.others, uid: uid, gid: gid, sticky: current.sticky)
    }

    public func changeRecursive(uid: Bool, sticky: Bool) throws {
        let current = permissions
        try changeRecursive(owner: current.owner, group: current.group, others: current.others, uid: uid, gid: current.gid, sticky: sticky)
    }

    public func changeRecursive(gid: Bool, sticky: Bool) throws {
        let current = permissions
        try changeRecursive(owner: current.owner, group: current.group, others: current.others, uid: current.uid, gid: gid, sticky: sticky)
    }

    public func changeRecursive(uid: Bool, gid: Bool, sticky: Bool) throws {
        let current = permissions
        try changeRecursive(owner: current.owner, group: current.group, others: current.others, uid: uid, gid: gid, sticky: sticky)
    }
}
