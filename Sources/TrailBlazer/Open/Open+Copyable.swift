extension Open: Copyable where PathType: Copyable {
    public typealias CopyablePathType = PathType.CopyablePathType

    @discardableResult
    public func copy(to newPath: inout PathType.CopyablePathType,
                     options: CopyOptions = []) throws -> Open<PathType.CopyablePathType> {
        return try path.copy(to: &newPath, options: options)
    }
}

