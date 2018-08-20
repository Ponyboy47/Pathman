public extension Bool {
    public func toggled() -> Bool { return !self }
    public mutating func toggle() { self = !self }
}
