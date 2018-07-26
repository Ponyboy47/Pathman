public struct StatOptions: OptionSet {
    public let rawValue: Int

    public static let getLinkInfo = StatOptions(rawValue: 1 << 0)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
