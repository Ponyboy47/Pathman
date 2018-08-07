infix operator !!: NilCoalescingPrecedence

/// Unwrap or die operator
public func !! <T>(lhs: T?, rhs: @autoclosure () -> String) -> T {
    if let val = lhs { return val }
    fatalError(rhs())
}

infix operator ?!: NilCoalescingPrecedence

/// Unwrap or throw operator
public func ?! <T>(lhs: T?, rhs: @autoclosure () -> Error) throws -> T {
    if let val = lhs { return val }
    throw rhs()
}
