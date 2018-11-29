extension DirectoryPath: Copyable {
    @discardableResult
    public func copy(to newPath: inout DirectoryPath, options: CopyOptions) throws -> Open<CopyablePathType> {
        let childPaths = try children(options: .init(copyOptions: options))

        // The cp(1) utility skips directories unless the recursive option is
        // used. Let's be a little nicer and only skip non-empty directories
        guard options.contains(.recursive) || childPaths.isEmpty else { throw CopyError.nonEmptyDirectory }

        let newOpenPath = try newPath.create(mode: permissions)
        try newOpenPath.change(owner: owner, group: group)

        // Copy the files into the new directory
        try childPaths.files.forEach { file in
            try file.copy(into: newPath, options: options)
        }
        // Copy the directories into the new directory
        try childPaths.directories.forEach { directory in
            try directory.copy(into: newPath, options: options)
        }

        // Sockets and undetermined path types cannot be copied
        let uncopyable = childPaths.sockets + childPaths.other
        guard uncopyable.isEmpty else { throw CopyError.uncopyablePath(uncopyable.first!) }

        return newOpenPath
    }
}

