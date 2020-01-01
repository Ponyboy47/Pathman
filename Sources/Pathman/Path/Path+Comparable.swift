/* swiftlint:disable identifier_name */
public extension Path {
    static func < (lhs: Self, rhs: Self) -> Bool {
        let lval = lhs.components.first
        let rval = rhs.components.first
        if let l = lval, let r = rval {
            return l < r
        } else if rval != nil {
            return false
        } else { // if lval != nil
            return true
        }
    }
}
