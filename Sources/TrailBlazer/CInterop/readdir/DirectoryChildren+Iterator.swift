extension DirectoryChildren: Sequence {
    public struct Iterator: IteratorProtocol {
        let components: [GenericPath]
        var idx: Array<GenericPath>.Index

        init(_ children: DirectoryChildren) {
            components = children.files + children.directories + children.sockets + children.other
            idx = components.startIndex
        }

        public mutating func next() -> GenericPath? {
            guard idx < components.endIndex else { return nil }
            defer { idx = idx.advanced(by: 1) }
            return components[idx]
        }
    }

    public func makeIterator() -> Iterator {
        return Iterator(self)
    }

    public var notDirectories: [GenericPath] { return files + sockets + other }
    public var notOther: [GenericPath] { return files + sockets + directories }
}

public extension Array where Element == FilePath {
    static func + (lhs: [Element], rhs: [GenericPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs
    }
    static func + (lhs: [GenericPath], rhs: [Element]) -> [GenericPath] {
        return lhs + rhs.map(GenericPath.init)
    }
    static func + (lhs: [Element], rhs: [DirectoryPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
    static func + (lhs: [Element], rhs: [SocketPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
}

public extension Array where Element == DirectoryPath {
    static func + (lhs: [Element], rhs: [GenericPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs
    }
    static func + (lhs: [GenericPath], rhs: [Element]) -> [GenericPath] {
        return lhs + rhs.map(GenericPath.init)
    }
    static func + (lhs: [Element], rhs: [FilePath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
    static func + (lhs: [Element], rhs: [SocketPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
}

public extension Array where Element == SocketPath {
    static func + (lhs: [Element], rhs: [GenericPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs
    }
    static func + (lhs: [GenericPath], rhs: [Element]) -> [GenericPath] {
        return lhs + rhs.map(GenericPath.init)
    }
    static func + (lhs: [Element], rhs: [DirectoryPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
    static func + (lhs: [Element], rhs: [FilePath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
}
