extension Path {
    /**
    A relative representation of the current path by replacing the home
    directory with ~ or by resolving the current working directory to .

    NOTE: Be careful with this. If the current working directory is replaced
    with a . and then the current working directory changes, then this path no
    longer points to the same place
    */
    public var relative: Self {
        var str = path
        if let home = home?.string, str.hasPrefix(home) {
            str = str.replacingOccurrences(of: home, with: "~")
        } else if str.hasPrefix(Self.cwd.string) {
            str = str.replacingOccurrences(of: cwd.string, with: ".")
        }

        return Self(str)!
    }

    /// Whether or not the current path contains relative items (., .., or ~)
    public var isRelative: Bool {
        let comps = components
        guard !comps.isEmpty else { return false }
        guard !comps.contains("..") else { return true }
        for relativeItem in ["~", "."] {
            guard !path.hasPrefix(relativeItem) else { return true }
        }
        return comps.first! != Self.separator && !path.hasPrefix(Self.root.path)
    }
}
