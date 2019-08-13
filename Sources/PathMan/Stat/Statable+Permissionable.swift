#if os(Linux)
import func Glibc.getegid
import func Glibc.geteuid
#else
import func Darwin.getegid
import func Darwin.geteuid
#endif

public extension Permissionable where Self: Statable {
    /// The permissions for the path
    var permissions: FileMode {
        get { return info.permissions }
        set { try? change(permissions: newValue) }
    }

    /// Whether or not the path may be read from by the calling process
    var isReadable: Bool {
        if geteuid() == owner, permissions.owner.isReadable {
            return true
        } else if getegid() == group, permissions.group.isReadable {
            return true
        }

        return permissions.others.isReadable
    }

    /// Whether or not the path may be read from by the calling process
    var isWritable: Bool {
        if geteuid() == owner, permissions.owner.isWritable {
            return true
        } else if getegid() == group, permissions.group.isWritable {
            return true
        }

        return permissions.others.isWritable
    }

    /// Whether or not the path may be read from by the calling process
    var isExecutable: Bool {
        if geteuid() == owner, permissions.owner.isExecutable {
            return true
        } else if getegid() == group, permissions.group.isExecutable {
            return true
        }

        return permissions.others.isExecutable
    }
}
