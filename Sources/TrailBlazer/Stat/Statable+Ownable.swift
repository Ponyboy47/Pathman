extension Ownable where Self: Statable {
    /// The uid of the owner of the path
    public var owner: UID {
        get { return info.owner }
        set { try? change(owner: newValue, group: ~0) }
    }

    /// The gid of the group that owns the path
    public var group: GID {
        get { return info.group }
        set { try? change(owner: ~0, group: newValue) }
    }
}

