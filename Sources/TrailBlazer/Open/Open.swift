import ErrNo

public typealias FileDescriptor = Int32

public protocol Openable: StatDelegate {
    func close() throws
}
