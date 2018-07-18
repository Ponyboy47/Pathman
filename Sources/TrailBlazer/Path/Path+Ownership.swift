#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol Ownable: StatDelegate {
    var owner: uid_t { get set }
    var group: gid_t { get set }
    var ownerName: String? { get set }
    var groupName: String? { get set }

    func change(owner uid: uid_t, group gid: gid_t) throws
}

public extension Ownable {
    public var owner: uid_t {
        get { return info.owner }
        set { try? change(owner: newValue, group: ~0) }
    }
    public var group: gid_t {
        get { return info.group }
        set { try? change(owner: ~0, group: newValue) }
    }

    public var ownerName: String? {
        get {
            guard let username = GenericPath.getUserInfo(owner)?.pw_name else { return nil }
            return String(cString: username)
        }
        set {
            guard let username = newValue else { return }
            try? change(owner: username)
        }
    }
    public var groupName: String? {
        get {
            guard let groupname = GenericPath.getGroupInfo(group)?.gr_name else { return nil }
            return String(cString: groupname)
        }
        set {
            guard let groupname = newValue else { return }
            try? change(group: groupname)
        }
    }

    public func change(owner username: String? = nil, group groupname: String? = nil) throws {
        let uid: uid_t = username != nil ? GenericPath.getUserInfo(username!)?.pw_uid ?? ~0 : ~0
        let gid: gid_t = groupname != nil ? GenericPath.getGroupInfo(groupname!)?.gr_gid ?? ~0 : ~0

        try change(owner: uid, group: gid)
    }
}
