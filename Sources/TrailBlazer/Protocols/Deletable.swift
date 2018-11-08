/// Paths that can be deleted
public protocol Deletable {
    /// Deletes a path
    mutating func delete() throws
}
