extension SocketPath {
    public static func bind(to address: SocketPath,
                            options: SocketOptions) throws -> Binding {
        return try address.open(options: options).bind()
    }

    public static func bind<Socket: SocketOption>(to address: SocketPath,
                                                  type: Socket.Type) throws -> Binding {
        return try SocketPath.bind(to: address, options: SocketOptions(type: type))
    }

    public static func bind(to address: SocketPath,
                            options: SocketOptions,
                            closure: (Binding) throws -> ()) throws {
        try closure(bind(to: address, options: options))
    }

    public static func bind<Socket: SocketOption>(to address: SocketPath,
                                                  type: Socket.Type,
                                                  closure: (Binding) throws -> ()) throws {
        try closure(bind(to: address, type: type))
    }

    public func bind(options: SocketOptions) throws -> Binding {
        return try SocketPath.bind(to: self, options: options)
    }

    public func bind<Socket: SocketOption>(type: Socket.Type) throws -> Binding {
        return try SocketPath.bind(to: self, type: type)
    }

    public func bind(options: SocketOptions,
                     closure: (Binding) throws -> ()) throws {
        try closure(bind(options: options))
    }

    public func bind<Socket: SocketOption>(type: Socket.Type,
                     closure: (Binding) throws -> ()) throws {
        try closure(bind(type: type))
    }
}
