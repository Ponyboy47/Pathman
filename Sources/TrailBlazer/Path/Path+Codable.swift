public extension Path {
    /**
    Decodes a Path from an unkeyed String container

    - Throws: `CodingError.incorrectPathType` when a path exists that does not match the encoded type
    */
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PathType.self)
        guard let pathString = try container.decodeIfPresent(String.self, forKey: Self.pathType) else {
            throw CodingError.incorrectPathType
        }
        guard let path = Self(pathString) else {
            throw CodingError.incorrectPathType
        }

        self.init(path)
    }

    /// Encodes a Path to an unkeyed String container
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PathType.self)
        try container.encode(string, forKey: Self.pathType)
    }
}
