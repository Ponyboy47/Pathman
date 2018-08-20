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
public protocol Linkable: Path, Deletable {
    associatedtype LinkablePathType: Linkable = Self
    func link(at: LinkablePathType, type: LinkType) throws -> LinkedPath<LinkablePathType>
    func link(from: LinkablePathType, type: LinkType) throws -> LinkedPath<LinkablePathType>
}

public extension Linkable {
    public static var defaultLinkType: LinkType {
        get { return TrailBlazer.defaultLinkType }
        set {
            TrailBlazer.defaultLinkType = newValue
        }
    }

    public func link(at linkedPath: LinkablePathType, type: LinkType = LinkablePathType.defaultLinkType) throws -> LinkedPath<LinkablePathType> {
        guard let targetPath = self as? LinkablePathType else { throw LinkError.pathTypeMismatch }
        return try LinkedPath(linkedPath, linked: (to: targetPath, type: type))
    }

    public func link(at linkedString: String, type: LinkType = LinkablePathType.defaultLinkType) throws -> LinkedPath<LinkablePathType> {
        guard let linkedPath = LinkablePathType(linkedString) else { throw LinkError.pathTypeMismatch }
        return try self.link(at: linkedPath, type: type)
    }

    public func link(from targetPath: LinkablePathType, type: LinkType = LinkablePathType.defaultLinkType) throws -> LinkedPath<LinkablePathType> {
        guard let linkedPath = self as? LinkablePathType else { throw LinkError.pathTypeMismatch }
        return try LinkedPath(linkedPath, linked: (to: targetPath, type: type))
    }

    public func link(from targetString: String, type: LinkType = LinkablePathType.defaultLinkType) throws -> LinkedPath<LinkablePathType> {
        guard let targetPath = LinkablePathType(targetString) else { throw LinkError.pathTypeMismatch }
        return try link(from: targetPath, type: type)
    }
}

public protocol Linked: Path {
    associatedtype LinkedPathType: Linkable
    typealias Link = (to: LinkedPathType, type: LinkType)

    var linked: Link? { get set }
    static var defaultLinkType: LinkType { get set }

    init(_ path: LinkedPathType, linked link: Link) throws
    func link(at: LinkedPathType, type: LinkType) throws -> LinkedPath<LinkedPathType>
    func link(from: LinkedPathType, type: LinkType) throws -> LinkedPath<LinkedPathType>
    func unlink() throws
}

public extension Linked {
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

    public static var defaultLinkType: LinkType {
        get { return TrailBlazer.defaultLinkType }
        set {
            TrailBlazer.defaultLinkType = newValue
        }
    }

    public init(_ path: String, linked link: Link) throws {
        let pathLink = try LinkedPathType.init(path) ?! LinkError.pathTypeMismatch
        try self.init(pathLink, linked: link)
    }

    public init(_ path: String, linkedTo link: LinkedPathType, type: LinkType = Self.defaultLinkType) throws {
        try self.init(path, linked: (to: link, type: type))
    }

    public init(_ path: LinkedPathType, linkedTo link: LinkedPathType, type: LinkType = Self.defaultLinkType) throws {
        try self.init(path, linked: (to: link, type: type))
    }

    public init(_ path: LinkedPathType, linkedTo link: String, type: LinkType = Self.defaultLinkType) throws {
        let linkedPath = try LinkedPathType.init(link) ?! LinkError.pathTypeMismatch
        try self.init(path, linked: (to: linkedPath, type: type))
    }

    public func link(at linkedPath: LinkedPathType, type: LinkType = Self.defaultLinkType) throws -> LinkedPath<LinkedPathType> {
        guard let targetPath = self as? LinkedPathType else { throw LinkError.pathTypeMismatch }
        return try LinkedPath(linkedPath, linked: (to: targetPath, type: type))
    }

    public func link(at linkedString: String, type: LinkType = LinkedPathType.defaultLinkType) throws -> LinkedPath<LinkedPathType> {
        guard let linkedPath = LinkedPathType(linkedString) else { throw LinkError.pathTypeMismatch }
        return try link(at: linkedPath, type: type)
    }

    public func link(from targetPath: LinkedPathType, type: LinkType = Self.defaultLinkType) throws -> LinkedPath<LinkedPathType> {
        guard let linkedPath = self as? LinkedPathType else { throw LinkError.pathTypeMismatch }
        return try LinkedPath(linkedPath, linked: (to: targetPath, type: type))
    }

    public func link(from targetString: String, type: LinkType = LinkedPathType.defaultLinkType) throws -> LinkedPath<LinkedPathType> {
        guard let targetPath = LinkedPathType(targetString) else { throw LinkError.pathTypeMismatch }
        return try link(from: targetPath, type: type)
    }

    public func unlink() throws {
        guard cUnlink(_path) != -1 else { throw UnlinkError.getError() }
    }
}

public class LinkedPath<PathType: Linkable>: Linked {
    public typealias LinkedPathType = PathType

    public var _path: String {
        get { return __path._path }
        set {
            __path._path = newValue
        }
    }
    private var __path: PathType

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

    private var _info: StatInfo = StatInfo()
    public var info: StatInfo {
        try? _info.getInfo()
        return _info
    }

    public required init(_ path: LinkedPathType, linked link: Link) throws {
        __path = path
        _info = path.info

        try createLink(from: path, to: link.to, type: link.type)
        _linked = link
    }

    public required init?(_ components: [String]) {
        guard let path = PathType(components) else { return nil }
        __path = path
        _info = path.info

        if path.exists {
            guard path.isLink else { return nil }
        }
    }

    public convenience init?(_ components: String...) {
        self.init(components)
    }

    public convenience init?(_ components: ArraySlice<String>) {
        self.init(Array(components))
    }

    public required init?(_ str: String) {
        guard let path = PathType(str) else { return nil }
        __path = path
        _info = path.info

        if path.exists {
            guard path.isLink else { return nil }
        }
    }

    public required init(_ path: LinkedPath<PathType>) {
        __path = path.__path
        _info = path.info
        _linked = path._linked
    }

    public required init?(_ path: GenericPath) {
        guard let _path = path as? PathType else { return nil }

        if path.exists {
            guard path.isLink else { return nil }
        }

        __path = _path
        _info = path.info
    }
}

func createLink<PathType: Path>(from: PathType, to: PathType, type: LinkType) throws {
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

extension LinkedPath: Creatable {
    @available(*, renamed: "init", renamed: "link", message: "LinkedPaths cannot be created directly, instead use the PathType.link(to/from: PathType, type: LinkType) function or LinkedPath.init(_ path: PathType, linked: (to: PathType, type: LinkType))")
    public func create(mode: FileMode, ignoreUMask: Bool = false) throws -> Open<PathType> {
        fatalError("LinkedPaths should not be created directly")
    }
}

extension LinkedPath: Deletable {
    public func delete() throws {
        try __path.delete()
    }
}

extension LinkedPath: Openable {
    public typealias OpenableType = PathType.OpenableType

    public var fileDescriptor: FileDescriptor { return __path.fileDescriptor }
    public var options: OptionInt { return __path.options }
    public var mode: FileMode? { return __path.mode }

    public func open(options: OptionInt = 0, mode: FileMode? = nil) throws -> Open<OpenableType> {
        return try __path.open(options: options, mode: mode)
    }

    public func close() throws {
        try __path.close()
    }
}
