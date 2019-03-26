public extension SocketPath {
    static func bind(to address: SocketPath,
                     options: SocketOptions) throws -> Binding {
        return try address.open(options: options).bind()
    }

    static func bind(to address: SocketPath,
                     type: SocketType) throws -> Binding {
        return try address.open(type: type).bind()
    }

    static func bind(to address: SocketPath) throws -> Binding {
        return try SocketPath.bind(to: address, type: .stream)
    }

    static func bind(to address: SocketPath,
                     options: SocketOptions,
                     closure: (Binding) throws -> Void) throws {
        try closure(bind(to: address, options: options))
    }

    static func bind(to address: SocketPath,
                     type: SocketType,
                     closure: (Binding) throws -> Void) throws {
        try closure(bind(to: address, type: type))
    }

    static func bind(to address: SocketPath,
                     closure: (Binding) throws -> Void) throws {
        try closure(bind(to: address))
    }

    func bind(options: SocketOptions) throws -> Binding {
        return try SocketPath.bind(to: self, options: options)
    }

    func bind(type: SocketType) throws -> Binding {
        return try SocketPath.bind(to: self, type: type)
    }

    func bind() throws -> Binding {
        return try SocketPath.bind(to: self)
    }

    func bind(options: SocketOptions,
              closure: (Binding) throws -> Void) throws {
        try closure(bind(options: options))
    }

    func bind(type: SocketType,
              closure: (Binding) throws -> Void) throws {
        try closure(bind(type: type))
    }

    func bind(closure: (Binding) throws -> Void) throws {
        try closure(bind())
    }
}
