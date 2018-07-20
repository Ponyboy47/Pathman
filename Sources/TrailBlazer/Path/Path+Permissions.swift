public protocol Permissionable: StatDelegate {
    var permissions: FileMode { get set }
    func change(permissions: FileMode) throws
}

public extension Permissionable {
    public var permissions: FileMode {
        get { return info.permissions }
        set { try? change(permissions: newValue) }
    }

    public func change(owner: FilePermissions, group: FilePermissions, others: FilePermissions, bits: FileBits) throws {
        try change(permissions: FileMode(owner: owner, group: group, others: others, bits: bits))
    }

    public func change(owner: FilePermissions? = nil, group: FilePermissions? = nil, others: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: owner ?? current.owner, group: group ?? current.group, others: others ?? current.others, bits: bits ?? current.bits)
    }

    public func change(ownerGroup perms: FilePermissions, others: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: perms, group: perms, others: current.others, bits: bits ?? current.bits)
    }

    public func change(ownerOthers perms: FilePermissions, group: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: perms, group: group ?? current.group, others: perms, bits: bits ?? current.bits)
    }

    public func change(groupOthers perms: FilePermissions, owner: FilePermissions? = nil, bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: owner ?? current.owner, group: perms, others: perms, bits: bits ?? current.bits)
    }

    public func change(ownerGroupOthers perms: FilePermissions, bits: FileBits? = nil) throws {
        try change(owner: perms, group: perms, others: perms, bits: bits ?? permissions.bits)
    }
}
