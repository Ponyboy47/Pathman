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
