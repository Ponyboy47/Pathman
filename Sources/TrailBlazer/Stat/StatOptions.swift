/// Options when making the stat API calls
public struct StatOptions: OptionSet, Hashable {
    public let rawValue: Int

    /// Get information about a symlink instead of the path it points to
    public static let getLinkInfo = StatOptions(rawValue: 1 << 0)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
