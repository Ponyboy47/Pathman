/// A Path that has an owner and a group associated with it
public protocol Ownable {
    /// The uid of the user that owns the file
    var owner: UID { get set }
    /// The gid of the group that owns the file
    var group: GID { get set }
    /// The name of the user that owns the file
    var ownerName: String? { get set }
    /// The name of the group that owns the file
    var groupName: String? { get set }

    mutating func change(owner uid: UID, group gid: GID) throws
}

public extension Ownable {
    var ownerName: String? {
        get {
            guard let username = (try? getUserInfo(uid: owner))?.pw_name else { return nil }
            return String(cString: username)
        }
        set {
            guard let username = newValue else { return }
            try? change(owner: username)
        }
    }
    var groupName: String? {
        get {
            guard let groupname = (try? getGroupInfo(gid: group))?.gr_name else { return nil }
            return String(cString: groupname)
        }
        set {
            guard let groupname = newValue else { return }
            try? change(group: groupname)
        }
    }

    mutating func change(owner username: String? = nil, group groupname: String? = nil) throws {
        let uid: UID
        let gid: GID

        if let username = username {
            uid = try getUserInfo(username: username).pw_uid
        } else {
            uid = ~0
        }

        if let groupname = groupname {
            gid = try getGroupInfo(groupname: groupname).gr_gid
        } else {
            gid = ~0
        }

        try change(owner: uid, group: gid)
    }
}
