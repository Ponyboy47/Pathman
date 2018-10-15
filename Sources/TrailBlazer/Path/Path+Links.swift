#if os(Linux)
import Glibc
let cLink = Glibc.link
let cSymlink = Glibc.symlink
let cUnlink = Glibc.unlink
#else
import Darwin
let cLink = Darwin.link
let cSymlink = Darwin.symlink
let cUnlink = Darwin.unlink
#endif

public enum LinkType {
    case hard
    case symbolic
    public static let soft: LinkType = .symbolic
}

public var defaultLinkType: LinkType = .symbolic

/// A protocol declaration for Paths that can be symbolically linked to
public protocol Linkable: Path {
    func link(at: Self, type: LinkType) throws -> LinkedPath<Self>
    func link(from: Self, type: LinkType) throws -> LinkedPath<Self>
}

public extension Linkable {
    public func link(at linkedPath: Self, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        return try LinkedPath(linkedPath, linked: (to: self, type: type))
    }

    public func link(at linkedString: String, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        guard let linkedPath = Self(linkedString) else { throw LinkError.pathTypeMismatch }
        return try self.link(at: linkedPath, type: type)
    }

    public func link(from targetPath: Self, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        return try LinkedPath(self, linked: (to: targetPath, type: type))
    }

    public func link(from targetString: String, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        guard let targetPath = Self(targetString) else { throw LinkError.pathTypeMismatch }
        return try link(from: targetPath, type: type)
    }
}

public struct LinkedPath<LinkedPathType: Linkable>: Linkable {
    public typealias Link = (to: LinkedPathType, type: LinkType)

    public var _path: String {
        get { return __path._path }
        set {
            __path._path = newValue
        }
    }
    private var __path: LinkedPathType

    private var _linked: Link? = nil
    public var linked: Link? {
        get { return _linked }
        set {
            if let newVal = newValue {
                guard (try? link(from: newVal.to, type: newVal.type)) != nil else { return }
            } else {
                guard (try? unlink()) != nil else { return }
            }
            _linked = newValue
        }
    }

    public var _info: StatInfo = StatInfo()

    public var linkedTo: LinkedPathType? {
        get { return linked?.to }
        set {
            // If we're just changing which file the link points to, go ahead
            // and do that
            if let link = newValue, let type = linkType {
                linked = (to: link, type: type)
                // If we're setting the link location to nil, then we'll unlink
            } else if linkType != nil {
                try? unlink()
                // If the link type is nil, then we can't set/create a new link. So
                // do nothing.
            } else if let link = newValue {
                linked = (to: link, type: TrailBlazer.defaultLinkType)
            }
        }
    }
    public var linkType: LinkType? {
        get { return linked?.type }
        set {
            // If we're just changing the link type, then go ahead and do it
            if let type = newValue, let link = linkedTo {
                linked = (to: link, type: type)
                // If we're setting the link type to nil, then we'll unlink
            } else if linkedTo != nil {
                try? unlink()
            }
            // If the link location is nil, then we can't set/create a new
            // link. So do nothing.
        }
    }

    public var isLink: Bool { return linkType != nil }

    public var isDangling: Bool {
        guard let _linked = linked else { return true }

        // If the path we're linked to exists then the link is not dangling.
        // Hard links cannot be dangling.
        return _linked.type == .hard ? false : _linked.to.exists.toggled()
    }

    public init(_ path: String, linked link: Link) throws {
        let pathLink = try LinkedPathType.init(path) ?! LinkError.pathTypeMismatch
        try self.init(pathLink, linked: link)
    }

    public init(_ path: String, linkedTo link: LinkedPathType, type: LinkType = TrailBlazer.defaultLinkType) throws {
        try self.init(path, linked: (to: link, type: type))
    }

    public init(_ path: LinkedPathType, linkedTo link: LinkedPathType, type: LinkType = TrailBlazer.defaultLinkType) throws {
        try self.init(path, linked: (to: link, type: type))
    }

    public init(_ path: LinkedPathType, linkedTo link: String, type: LinkType = TrailBlazer.defaultLinkType) throws {
        let linkedPath = try LinkedPathType.init(link) ?! LinkError.pathTypeMismatch
        try self.init(path, linked: (to: linkedPath, type: type))
    }

    public func link(at linkedPath: LinkedPathType, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<LinkedPathType> {
        guard let targetPath = self as? LinkedPathType else { throw LinkError.pathTypeMismatch }
        return try LinkedPath(linkedPath, linked: (to: targetPath, type: type))
    }

    public func link(at linkedString: String, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<LinkedPathType> {
        guard let linkedPath = LinkedPathType(linkedString) else { throw LinkError.pathTypeMismatch }
        return try link(at: linkedPath, type: type)
    }

    public func link(from targetPath: LinkedPathType, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<LinkedPathType> {
        guard let linkedPath = self as? LinkedPathType else { throw LinkError.pathTypeMismatch }
        return try LinkedPath(linkedPath, linked: (to: targetPath, type: type))
    }

    public func link(from targetString: String, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<LinkedPathType> {
        guard let targetPath = LinkedPathType(targetString) else { throw LinkError.pathTypeMismatch }
        return try link(from: targetPath, type: type)
    }

    public func unlink() throws {
        guard cUnlink(_path) != -1 else { throw UnlinkError.getError() }
    }
    public init(_ path: LinkedPathType, linked link: Link) throws {
        __path = LinkedPathType(path)
        _info._path = path.string

        try createLink(from: path, to: link.to, type: link.type)
        _linked = link
    }

    public init?(_ components: [String]) {
        guard let path = LinkedPathType(components) else { return nil }
        __path = path
        _info._path = path.string

        if path.exists {
            guard path.isLink else { return nil }
        }
    }

    public init?(_ str: String) {
        guard let path = LinkedPathType(str) else { return nil }
        __path = path
        _info._path = path.string

        if path.exists {
            guard path.isLink else { return nil }
        }
    }

    public init(_ path: LinkedPath<LinkedPathType>) {
        __path = LinkedPathType(path.__path)
        _info._path = path.string
        _linked = path._linked
    }

    public init?(_ path: GenericPath) {
        guard let _path = path as? LinkedPathType else { return nil }

        if path.exists {
            guard path.isLink else { return nil }
        }

        __path = LinkedPathType(_path)
        _info._path = path.string
    }
}

extension LinkedPath: Deletable where LinkedPathType: Deletable {
    public func delete() throws {
        try __path.delete()
    }
}

extension LinkedPath where LinkedPathType: Openable {
    public func open(options: LinkedPathType.OpenOptionsType) throws -> Open<LinkedPathType> {
        return try __path.open(options: options)
    }

    public static func close(descriptor: LinkedPathType.DescriptorType) throws {
        try LinkedPathType.close(descriptor: descriptor)
    }
}

private func createLink<PathType: Path>(from: PathType, to: PathType, type: LinkType) throws {
    let linkFunc: (UnsafePointer<CChar>, UnsafePointer<CChar>) -> OptionInt
    let linkError: TrailBlazerError.Type
    switch type {
    case .hard:
        linkFunc = cLink
        linkError = LinkError.self
    case .soft, .symbolic:
        linkFunc = cSymlink
        linkError = SymlinkError.self
    default: throw LinkError.noLinkType
    }

    guard linkFunc(to.string, from.string) != -1 else { throw linkError.getError() }
}
