public extension Path {
    /**
    Determine if two paths are equivalent

    - Parameter lhs: The path to compare
    - Parameter rhs: The path to compare the lhs against

    - Returns: Whether or not the paths are the same
    */
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.string == rhs.string
    }
    /**
    Determine if two paths are equivalent

    - Parameter lhs: The path to compare
    - Parameter rhs: The path to compare the lhs against

    - Returns: Whether or not the paths are the same
    */
    static func == <PathType: Path>(lhs: Self, rhs: PathType) -> Bool {
        return lhs.string == rhs.string
    }
}
