import ErrNo

public typealias FileDescriptor = Int32

public protocol Openable: StatDelegate {
    associatedtype PathType: Path
    func close() throws
}
