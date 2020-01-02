extension DirectoryChildren {
    public func sorted() -> DirectoryChildren {
        return DirectoryChildren(files: files.sorted(),
                                 directories: directories.sorted(),
                                 sockets: sockets.sorted(),
                                 characters: characters.sorted(),
                                 other: other.sorted())
    }

    public func sorted(_ predicate: (GenericPath, GenericPath) throws -> Bool) rethrows -> DirectoryChildren {
        let files = try self.files.lazy.map(GenericPath.init).sorted(by: predicate).map(FilePath.init)
        let directories = try self.directories.lazy.map(GenericPath.init).sorted(by: predicate).map(DirectoryPath.init)
        let sockets = try self.sockets.lazy.map(GenericPath.init).sorted(by: predicate).map(SocketPath.init)
        let characters = try self.characters.lazy.map(GenericPath.init).sorted(by: predicate).map(CharacterPath.init)
        let other = try self.other.sorted(by: predicate)
        return DirectoryChildren(files: files,
                                 directories: directories,
                                 sockets: sockets,
                                 characters: characters,
                                 other: other)
    }

    public mutating func sort() {
        files.sort()
        directories.sort()
        sockets.sort()
        characters.sort()
        other.sort()
    }

    public mutating func sort(_ predicate: (GenericPath, GenericPath) throws -> Bool) rethrows {
        files = try files.lazy.map(GenericPath.init).sorted(by: predicate).map(FilePath.init)
        directories = try directories.lazy.map(GenericPath.init).sorted(by: predicate).map(DirectoryPath.init)
        sockets = try sockets.lazy.map(GenericPath.init).sorted(by: predicate).map(SocketPath.init)
        characters = try characters.lazy.map(GenericPath.init).sorted(by: predicate).map(CharacterPath.init)
        other = try other.sorted(by: predicate)
    }
}
