extension SocketPath {
    public func bind<AddressType: Address>(to address: AddressType,
                                           options: SocketOptions) throws -> Binding {
        return try open(options: options).bind(to: address)
    }

    public func bind<AddressType: Address,
                     Socket: SocketOption>(to address: AddressType,
                                           type: Socket.Type) throws -> Binding {
        return try bind(to: address, options: SocketOptions(type: type))
    }
}
