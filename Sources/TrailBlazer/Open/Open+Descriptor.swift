public protocol Descriptor {
    var fileDescriptor: FileDescriptor { get }
}

extension FileDescriptor: Descriptor {
    public var fileDescriptor: FileDescriptor { return self }
}
