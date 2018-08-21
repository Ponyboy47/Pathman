public extension Bool {
    public func toggled() -> Bool { return !self }
    // This is provided automatically in swift 4.2
    // public mutating func toggle() { self = !self }
}
