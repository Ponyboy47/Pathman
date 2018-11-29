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

extension Array where Element == FilePath {
    public static func + (lhs: [Element], rhs: [GenericPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs
    }
    public static func + (lhs: [GenericPath], rhs: [Element]) -> [GenericPath] {
        return lhs + rhs.map(GenericPath.init)
    }
    public static func + (lhs: [Element], rhs: [DirectoryPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
    public static func + (lhs: [Element], rhs: [SocketPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
}

extension Array where Element == DirectoryPath {
    public static func + (lhs: [Element], rhs: [GenericPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs
    }
    public static func + (lhs: [GenericPath], rhs: [Element]) -> [GenericPath] {
        return lhs + rhs.map(GenericPath.init)
    }
    public static func + (lhs: [Element], rhs: [FilePath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
    public static func + (lhs: [Element], rhs: [SocketPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
}

extension Array where Element == SocketPath {
    public static func + (lhs: [Element], rhs: [GenericPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs
    }
    public static func + (lhs: [GenericPath], rhs: [Element]) -> [GenericPath] {
        return lhs + rhs.map(GenericPath.init)
    }
    public static func + (lhs: [Element], rhs: [DirectoryPath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
    public static func + (lhs: [Element], rhs: [FilePath]) -> [GenericPath] {
        return lhs.map(GenericPath.init) + rhs.map(GenericPath.init)
    }
}
