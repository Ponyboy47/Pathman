public typealias OpenDirectory = Open<DirectoryPath>

extension Open: Sequence, IteratorProtocol where PathType == DirectoryPath {
    public typealias Element = GenericPath

    public func children() -> DirectoryChildren {
        // Since the directory is already opened, getting the immediate
        // children is always safe
        return try! path.children()
    }

    public func recursiveChildren(depth: Int = -1) throws -> DirectoryChildren {
        return try path.recursiveChildren(depth: depth)
    }

    private func recursiveChildren(to depth: Int, at cur: Int = 0, children: DirectoryChildren = (files: [], directories: [], other: [])) throws -> DirectoryChildren {
        return try path.recursiveChildren(to: depth, at: cur)
    }

    public func next() -> GenericPath? {
        return path.next()
    }
}
