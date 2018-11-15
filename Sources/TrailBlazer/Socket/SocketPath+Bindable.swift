extension SocketPath {
    public static func bind(to address: SocketPath,
                            options: SocketOptions) throws -> Binding {
        return try address.open(options: options).bind()
    }

    public static func bind(to address: SocketPath,
                            type: SocketType) throws -> Binding {
        return try SocketPath.bind(to: address, options: SocketOptions(type: type))
    }

    public static func bind(to address: SocketPath) throws -> Binding {
        return try SocketPath.bind(to: address, type: .stream)
    }

    public static func bind(to address: SocketPath,
                            options: SocketOptions,
                            closure: (Binding) throws -> ()) throws {
        try closure(bind(to: address, options: options))
    }

    public static func bind(to address: SocketPath,
                            type: SocketType,
                            closure: (Binding) throws -> ()) throws {
        try closure(bind(to: address, type: type))
    }

    public static func bind(to address: SocketPath,
                            closure: (Binding) throws -> ()) throws {
        try closure(bind(to: address))
    }

    public func bind(options: SocketOptions) throws -> Binding {
        return try SocketPath.bind(to: self, options: options)
    }

    public func bind(type: SocketType) throws -> Binding {
        return try SocketPath.bind(to: self, type: type)
    }

    public func bind() throws -> Binding {
        return try SocketPath.bind(to: self)
    }

    public func bind(options: SocketOptions,
                     closure: (Binding) throws -> ()) throws {
        try closure(bind(options: options))
    }

    public func bind(type: SocketType,
                     closure: (Binding) throws -> ()) throws {
        try closure(bind(type: type))
    }

    public func bind(closure: (Binding) throws -> ()) throws {
        try closure(bind())
    }
}
