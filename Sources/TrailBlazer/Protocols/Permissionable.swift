/// A Path that can be constrained with permissions
public protocol Permissionable {
    /// The permissions of the path
    var permissions: FileMode { get set }
    mutating func change(permissions: FileMode) throws
}

public extension Permissionable {
    mutating func change(owner: FilePermissions,
                         group: FilePermissions,
                         others: FilePermissions,
                         bits: FileBits) throws {
        try change(permissions: FileMode(owner: owner, group: group, others: others, bits: bits))
    }

    mutating func change(owner: FilePermissions? = nil,
                         group: FilePermissions? = nil,
                         others: FilePermissions? = nil,
                         bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: owner ?? current.owner,
                   group: group ?? current.group,
                   others: others ?? current.others,
                   bits: bits ?? current.bits)
    }

    mutating func change(ownerGroup perms: FilePermissions,
                         others: FilePermissions? = nil,
                         bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: perms, group: perms, others: current.others, bits: bits ?? current.bits)
    }

    mutating func change(ownerOthers perms: FilePermissions,
                         group: FilePermissions? = nil,
                         bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: perms, group: group ?? current.group, others: perms, bits: bits ?? current.bits)
    }

    mutating func change(groupOthers perms: FilePermissions,
                         owner: FilePermissions? = nil,
                         bits: FileBits? = nil) throws {
        let current = permissions
        try change(owner: owner ?? current.owner, group: perms, others: perms, bits: bits ?? current.bits)
    }

    mutating func change(ownerGroupOthers perms: FilePermissions, bits: FileBits? = nil) throws {
        try change(owner: perms, group: perms, others: perms, bits: bits ?? permissions.bits)
    }
}
