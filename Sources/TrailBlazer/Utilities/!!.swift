infix operator !!: NilCoalescingPrecedence

public func !! <T>(lhs: T?, rhs: String) -> T {
    guard let val = lhs else {
        fatalError(rhs)
    }
    return val
}
