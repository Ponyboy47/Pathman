public extension Copyable where Self: Openable {
    @discardableResult
    func copy(into directory: DirectoryPath, options: CopyOptions = []) throws -> Open<CopyablePathType> {
        // swiftlint:disable identifier_name
        let _newPath = directory + lastComponent!
        // swiftlint:enable identifier_name
        var newPath = CopyablePathType(_newPath) !! "Somehow, a different type of path ended up at \(_newPath)"

        return try copy(to: &newPath, options: options)
    }
}
