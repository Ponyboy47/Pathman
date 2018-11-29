public struct PathIterator: IteratorProtocol {
    let components: [String]
    var idx: Array<String>.Index

    init<PathType: Path>(_ path: PathType) {
        components = path.components
        idx = components.startIndex
    }

    public mutating func next() -> String? {
        guard idx < components.endIndex else { return nil }
        defer { idx = idx.advanced(by: 1) }
        return components[idx]
    }
}

extension Path {
    public func makeIterator() -> PathIterator {
        return PathIterator(self)
    }
}
