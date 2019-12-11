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

public extension Array where Element: Path {
    static func + <PathType: Path>(lhs: [Element], rhs: [PathType]) -> [GenericPath] {
        var new: [GenericPath]
        if let lhs = lhs as? [GenericPath] {
            new = lhs
        } else {
            new = lhs.map(GenericPath.init)
        }

        if let rhs = rhs as? [GenericPath] {
            new.append(contentsOf: rhs)
        } else {
            new.append(contentsOf: rhs.map(GenericPath.init))
        }

        return new
    }
}
