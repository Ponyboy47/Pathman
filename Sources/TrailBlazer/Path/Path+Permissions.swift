public protocol Permissionable: StatDelegate {
    var permissions: FileMode { get set }
    func change(permissions: FileMode) throws
}

public extension Permissionable {
    public var permissions: FileMode {
        get { return info.permissions }
        set { try? change(permissions: newValue) }
    }

    public func change(owner: FilePermissions, group: FilePermissions, others: FilePermissions, uid: Bool, gid: Bool, sticky: Bool) throws {
        try change(permissions: FileMode(owner: owner, group: group, others: others, uid: uid, gid: gid, sticky: sticky))
    }

    public func change(owner perms: FilePermissions...) throws {
        let current = permissions
        try change(owner: FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue })), group: current.group, others: current.others, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func change(group perms: FilePermissions...) throws {
        let current = permissions
        try change(owner: current.owner, group: FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue })), others: current.others, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func change(others perms: FilePermissions...) throws {
        let current = permissions
        try change(owner: current.owner, group: current.group, others: FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue })), uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func change(ownerGroup perms: FilePermissions...) throws {
        let perm = FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue }))
        let current = permissions
        try change(owner: perm, group: perm, others: current.others, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func change(ownerOthers perms: FilePermissions...) throws {
        let perm = FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue }))
        let current = permissions
        try change(owner: perm, group: current.group, others: perm, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func change(groupOthers perms: FilePermissions...) throws {
        let perm = FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue }))
        let current = permissions
        try change(owner: current.owner, group: perm, others: perm, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func change(ownerGroupOthers perms: FilePermissions...) throws {
        let perm = FilePermissions(rawValue: perms.reduce(0, { $0 | $1.rawValue }))
        let current = permissions
        try change(owner: perm, group: perm, others: perm, uid: current.uid, gid: current.gid, sticky: current.sticky)
    }

    public func change(uid: Bool) throws {
        let current = permissions
        try change(owner: current.owner, group: current.group, others: current.others, uid: uid, gid: current.gid, sticky: current.sticky)
    }

    public func change(gid: Bool) throws {
        let current = permissions
        try change(owner: current.owner, group: current.group, others: current.others, uid: current.uid, gid: gid, sticky: current.sticky)
    }

    public func change(sticky: Bool) throws {
        let current = permissions
        try change(owner: current.owner, group: current.group, others: current.others, uid: current.uid, gid: current.gid, sticky: sticky)
    }

    public func change(uid: Bool, gid: Bool) throws {
        let current = permissions
        try change(owner: current.owner, group: current.group, others: current.others, uid: uid, gid: gid, sticky: current.sticky)
    }

    public func change(uid: Bool, sticky: Bool) throws {
        let current = permissions
        try change(owner: current.owner, group: current.group, others: current.others, uid: uid, gid: current.gid, sticky: sticky)
    }

    public func change(gid: Bool, sticky: Bool) throws {
        let current = permissions
        try change(owner: current.owner, group: current.group, others: current.others, uid: current.uid, gid: gid, sticky: sticky)
    }

    public func change(uid: Bool, gid: Bool, sticky: Bool) throws {
        let current = permissions
        try change(owner: current.owner, group: current.group, others: current.others, uid: uid, gid: gid, sticky: sticky)
    }
}
