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

extension Path {
    public func link(at linkedPath: Self, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        return try LinkedPath(linkedPath, linkedTo: self, type: type)
    }

    public func link(at linkedString: String, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        guard let linkedPath = Self(linkedString) else { throw LinkError.pathTypeMismatch }
        return try self.link(at: linkedPath, type: type)
    }

    public func link(from targetPath: Self, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        return try LinkedPath(self, linkedTo: targetPath, type: type)
    }

    public func link(from targetString: String, type: LinkType = TrailBlazer.defaultLinkType) throws -> LinkedPath<Self> {
        guard let targetPath = Self(targetString) else { throw LinkError.pathTypeMismatch }
        return try link(from: targetPath, type: type)
    }
}

public struct LinkedPath<LinkedPathType: Path>: Path {
    public var _path: String {
        get { return __path._path }
        set { __path._path = newValue }
    }
    private var __path: LinkedPathType

    public let _info: StatInfo

    public private(set) var link: LinkedPathType
    public private(set) var linkType: LinkType

    public let isLink: Bool = true

    public var isDangling: Bool {
        // If the path we're linked to exists then the link is not dangling.
        // Hard links cannot be dangling.
        return linkType == .hard ? false : link.exists.toggled()
    }

    public init(_ path: String, linkedTo link: LinkedPathType, type: LinkType = TrailBlazer.defaultLinkType) throws {
        let pathLink = try LinkedPathType.init(path) ?! LinkError.pathTypeMismatch
        try self.init(pathLink, linkedTo: link, type: type)
    }

    public init(_ path: LinkedPathType, linkedTo link: String, type: LinkType = TrailBlazer.defaultLinkType) throws {
        let linkedPath = try LinkedPathType.init(link) ?! LinkError.pathTypeMismatch
        try self.init(path, linkedTo: linkedPath, type: type)
    }

    public func unlink() throws {
        guard cUnlink(_path) != -1 else { throw UnlinkError.getError() }
    }

    public init(_ path: LinkedPathType, linkedTo link: LinkedPathType, type: LinkType = TrailBlazer.defaultLinkType) throws {
        __path = LinkedPathType(path)
        _info = StatInfo(path.string)

        try createLink(from: path, to: link, type: type)
        self.link = link
        linkType = type
    }

    @available(*, renamed: "init(_:linkedTo:type:)")
    public init?(_ components: [String]) { fatalError("Cannot initialize a LinkedPath without specifying the path to link to") }

    @available(*, renamed: "init(_:linkedTo:type:)")
    public init?(_ str: String) { fatalError("Cannot initialize a LinkedPath without specifying the path to link to") }

    public init(_ path: LinkedPath<LinkedPathType>) {
        __path = LinkedPathType(path.__path)
        _info = StatInfo(path.string)
        link = path.link
        linkType = path.linkType
    }

    @available(*, renamed: "init(_:linkedTo:type:)")
    public init?(_ path: GenericPath) { fatalError("Cannot initialize a LinkedPath without specifying the path to link to") }
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
