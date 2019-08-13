public extension Path {
    func commonAncestor<PathType: Path>(with path: PathType) -> DirectoryPath? {
        let myComps = components
        let theirComps = path.components

        return myComps.count >= theirComps.count
            ? findCommonAncestry(larger: myComps, smaller: theirComps)
            : findCommonAncestry(larger: theirComps, smaller: myComps)
    }
}

private func findCommonAncestry(larger bigComps: [String], smaller lilComps: [String]) -> DirectoryPath? {
    var ancestry = [String]()
    for (idx, comp) in lilComps.enumerated() {
        guard comp == bigComps[idx] else { break }

        ancestry.append(comp)
    }

    let ancestors = DirectoryPath(ancestry) !! "Ancestry between paths does not represent a DirectoryPath"

    guard !ancestors.string.isEmpty else { return nil }

    return ancestors
}
