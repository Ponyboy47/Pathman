/* swiftlint:disable identifier_name */
public extension Path {
    static func < (lhs: Self, rhs: Self) -> Bool {
        let lval = lhs.components.first
        let rval = rhs.components.first
        if let l = lval, let r = rval {
            let nextL = Self(lhs.components.dropFirst())
            let nextR = Self(rhs.components.dropFirst())
            return l < r && nextL < nextR
        } else if rval != nil {
            return false
        } else { // if lval != nil
            return true
        }
    }
}
