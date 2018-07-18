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
}
