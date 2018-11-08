public struct CopyOptions: OptionSet {
    public let rawValue: Int

    /**
    If the path to copy is a directory, use this to recursively copy all of
    its contents as opposed to just its immediate children
    */
    public static let recursive = CopyOptions(rawValue: 1)
    /// If the path to copy is a directory, this option will copy the hidden files as well
    public static let includeHidden = CopyOptions(rawValue: 1 << 1)
    /**
    Instead of using a buffer to copy File contents into the duplicate,
    directly copy the entire file into the other. Beware of using this if the
    file you're copying is large
    */
    public static let noBuffer = CopyOptions(rawValue: 1 << 2)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public protocol Copyable {
    associatedtype CopyablePathType: Openable = Self
    @discardableResult
    func copy(to newPath: inout CopyablePathType, options: CopyOptions) throws -> Open<CopyablePathType>
}
