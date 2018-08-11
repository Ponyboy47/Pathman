#if os(Linux)
import Glibc
let cLink = Glibc.link
let cSymlink = Glibc.link
let cUnlink = Glibc.unlink
#else
import Darwin
let cLink = Darwin.link
let cSymlink = Darwin.link
let cUnlink = Darwin.unlink
#endif

public enum LinkType {
    case hard
    case symbolic
    public static let soft: LinkType = .symbolic
}

private var defaultType: LinkType = .symbolic

/// A protocol declaration for Paths that can be symbolically linked to
public protocol Linkable: Path {
    associatedtype LinkedPathType: Linkable
    typealias Link = (to: LinkedPathType, type: LinkType)

    var linked: Link? { get set }
    static var defaultType: LinkType { get set }

    init(_ path: LinkedPathType, linked link: Link) throws
    func link(at: LinkedPathType, type: LinkType) throws -> LinkedPath<LinkedPathType>
    func unlink() throws
}

public extension Linkable {
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
                linked = (to: link, type: TrailBlazer.defaultType)
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

    public static var defaultType: LinkType {
        get { return TrailBlazer.defaultType }
        set {
            TrailBlazer.defaultType = newValue
        }
    }

    public init(_ path: String, linked link: Link) throws {
        let pathLink = try LinkedPathType.init(path) ?! LinkError.pathTypeMismatch
        try self.init(pathLink, linked: link)
    }

    public init(_ path: String, linkedTo link: LinkedPathType, type: LinkType = .symbolic) throws {
        try self.init(path, linked: (to: link, type: type))
    }

    public init(_ path: LinkedPathType, linkedTo link: LinkedPathType, type: LinkType = .symbolic) throws {
        try self.init(path, linked: (to: link, type: type))
    }

    public init(_ path: LinkedPathType, linkedTo link: String, type: LinkType = .symbolic) throws {
        let linkedPath = try LinkedPathType.init(link) ?! LinkError.pathTypeMismatch
        try self.init(path, linked: (to: linkedPath, type: type))
    }

    public func link(at path: LinkedPathType, type: LinkType = .symbolic) throws -> LinkedPath<LinkedPathType> {
        guard let linkedPath = self as? LinkedPathType else { throw LinkError.pathTypeMismatch }
        return try LinkedPath(path, linked: (to: linkedPath, type: type))
    }

    public func unlink() throws {
        guard cUnlink(_path) != -1 else { throw UnlinkError.getError() }
    }
}

public class LinkedPath<PathType: Linkable>: Linkable {
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
                guard (try? link(at: newVal.to, type: newVal.type)) != nil else { return }
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
        linked = link

        try createLink(from: path, to: link.to, type: link.type)
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

    public init(_ path: LinkedPath<PathType>) {
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
