extension FilePath: Copyable {
    @discardableResult
    public func copy(to newPath: inout FilePath, options: CopyOptions = []) throws -> Open<FilePath> {
        guard exists else { throw CopyError.pathDoesNotExist }

        // Open self with read permissions
        let openPath = try open(mode: .read)

        // Create the path we're going to copy
        let newOpenPath = try newPath.create(mode: permissions)
        try newOpenPath.change(owner: owner, group: group)

        // If we're not buffering, the buffer size is just the whole file size.
        // If we are buffering, follow the Linux cp(1) implementation, which
        // reads 32 kb at a time.
        let bufferSize: Int = options.contains(.noBuffer) ? Int(size) : 32.kb

        // If we're not buffering, this should really only run once
        var totalWritten = 0
        repeat {
            totalWritten += try newOpenPath.write(openPath.read(bytes: bufferSize))
        } while totalWritten != openPath.size // Stop reading from the file once they're identically sized

        return newOpenPath
    }
}
