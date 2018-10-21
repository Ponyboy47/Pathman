#if os(Linux)
import Glibc
let cLink = Glibc.link
let cSymlink = Glibc.symlink
let cUnlink = Glibc.unlink
let cReadlink = Glibc.readlink
#else
import Darwin
let cLink = Darwin.link
let cSymlink = Darwin.symlink
let cUnlink = Darwin.unlink
let cReadlink = Darwin.readlink
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

    /// Initialize a symbolic link from an array of Path components
    public init?(_ components: [String]) {
        guard let path = LinkedPathType(components) else { return nil }
        __path = path
        _info = StatInfo(path.string)
        try? _info.getInfo()

        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX) + 1)
        defer {
            buffer.deinitialize(count: Int(PATH_MAX) + 1)
            buffer.deallocate()
        }

        let linkSize = cReadlink(path.string, buffer, Int(PATH_MAX))
        guard linkSize != -1 else { return nil }

        // realink(2) does not null-terminate the string stored in the buffer,
        // Swift expects it to be null-terminated to convert a cString to a Swift String
        buffer[linkSize] = 0
        guard let link = LinkedPathType.init(String(cString: buffer)) else { return nil }

        self.link = link
        linkType = .symbolic
    }

    /// Initialize a symbolic link from an array of Path components
    public init?(_ str: String) {
        guard let path = LinkedPathType(str) else { return nil }
        __path = path
        _info = StatInfo(path.string)
        try? _info.getInfo()

        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX) + 1)
        defer {
            buffer.deinitialize(count: Int(PATH_MAX) + 1)
            buffer.deallocate()
        }

        let linkSize = cReadlink(path.string, buffer, Int(PATH_MAX))
        guard linkSize != -1 else { return nil }

        // realink(2) does not null-terminate the string stored in the buffer,
        // Swift expects it to be null-terminated to convert a cString to a Swift String
        buffer[linkSize] = 0
        guard let link = LinkedPathType.init(String(cString: buffer)) else { return nil }

        self.link = link
        linkType = .symbolic
    }

    public init(_ path: LinkedPath<LinkedPathType>) {
        __path = LinkedPathType(path.__path)
        _info = StatInfo(path.string)
        try? _info.getInfo()
        link = path.link
        linkType = path.linkType
    }

    /// Initialize a symbolic link from an array of Path components
    public init?(_ path: GenericPath) {
        guard let _path = path as? LinkedPathType else { return nil }
        __path = _path
        _info = StatInfo(_path.string)
        try? _info.getInfo()

        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: Int(PATH_MAX) + 1)
        defer {
            buffer.deinitialize(count: Int(PATH_MAX) + 1)
            buffer.deallocate()
        }

        let linkSize = cReadlink(_path.string, buffer, Int(PATH_MAX))
        guard linkSize != -1 else { return nil }

        // realink(2) does not null-terminate the string stored in the buffer,
        // Swift expects it to be null-terminated to convert a cString to a Swift String
        buffer[linkSize] = 0
        guard let link = LinkedPathType.init(String(cString: buffer)) else { return nil }

        self.link = link
        linkType = .symbolic
    }
}

extension LinkedPath: Deletable where LinkedPathType: Deletable {
    public mutating func delete() throws {
        try __path.delete()
    }
}

extension LinkedPath where LinkedPathType: Openable {
    public func open(options: LinkedPathType.OpenOptionsType) throws -> Open<LinkedPathType> {
        return try __path.open(options: options)
    }
}

private func createLink<PathType: Path>(from: PathType, to: PathType, type: LinkType) throws {
    switch type {
    case .hard:
        guard cLink(to.string, from.string) != -1 else { throw LinkError.getError() }
    case .soft, .symbolic:
        guard cSymlink(to.string, from.string) != -1 else { throw SymlinkError.getError() }
    }
}
