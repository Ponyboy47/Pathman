import Cglob

public struct GlobFlags: OptionSet, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = OptionInt

    public private(set) var rawValue: IntegerLiteralType

    /// Append a slash to each path which corresponds to a directory.
    /// NOTE: I've commented this out because it is unecessary with the
    ///       PathCollection type return value for glob matches
    // public static let markDirectories: GlobFlags = GlobFlags(rawValue: GLOB_MARK)

    /** Return upon a read error (because a directory does not have read
    * permission, for example). By default, glob() attempts carry on despite
    * errors, reading all of the directories that it can.
    */
    public static let error: GlobFlags = GlobFlags(rawValue: GLOB_ERR)
    /** Don't sort the returned pathnames. The only reason to do this is to
    * save processing time. By default, the returned pathnames are sorted.
    */
    public static let unsorted: GlobFlags = GlobFlags(rawValue: GLOB_NOSORT)
    /** Reserve Glob().offset slots at the beginning of the list of strings in
    * pglob->pathv. The reserved slots contain null pointers.
    */
    public static let offset: GlobFlags = GlobFlags(rawValue: GLOB_DOOFFS)
    /** If no pattern matches, return the original pattern. By default, glob()
    * throws GlobError.noMatches if there are no matches.
    */
    public static let noCheck: GlobFlags = GlobFlags(rawValue: GLOB_NOCHECK)
    /** Append the results of this call to the vector of results returned by a
    * previous call to glob(). Do not set this flag on the first invocation of
    * glob().
    * NOTE: Only use this flag if you're reusing your own custom Glob() object
    * and are making multiple glob() calls
    */
    public static let append: GlobFlags = GlobFlags(rawValue: GLOB_APPEND)
    /** Don't allow backslash ('\') to be used as an escape character.
    * Normally, a backslash can be used to quote the following character,
    * providing a mechanism to turn off the special meaning metacharacters.
    */
    public static let noEscape: GlobFlags = GlobFlags(rawValue: GLOB_NOESCAPE)
    /** Allow a leading period to be matched by metacharacters. By default,
    * metacharacters can't match a leading period.
    */
    public static let period: GlobFlags = GlobFlags(rawValue: GLOB_PERIOD)
    /** Use alternative functions Glob().closedir, Glob().readdir,
    * Glob().opendir, Glob().lstat, and Glob().stat for filesystem access
    * instead of the normal library functions.
    */
    public static let alternativeDirectoryFunctions: GlobFlags = GlobFlags(rawValue: GLOB_ALTDIRFUNC)
    /** Expand csh(1) style brace expressions of the form {a,b}. Brace
    * expressions can be nested. Thus, for example, specifying the pattern
    * "{foo/{,cat,dog},bar}" would return the same results as four separate
    * glob() calls using the strings: "foo/", "foo/cat", "foo/dog", and "bar".
    */
    public static let brace: GlobFlags = GlobFlags(rawValue: GLOB_BRACE)
    /** If the pattern contains no metacharacters, then it should be returned
    * as the sole matching word, even if there is no file with that name.
    */
    public static let noMagic: GlobFlags = GlobFlags(rawValue: GLOB_NOMAGIC)
    /** Carry out tilde expansion. If a tilde ('~') is the only character in
    * the pattern, or an initial tilde is followed immediately by a slash
    * ('/'), then the home directory of the caller is substituted for the
    * tilde. If an initial tilde is followed by a username (e.g.,
    * "~andrea/bin"), then the tilde and username are substituted by the
    * home directory of that user. If the username is invalid, or the home
    * directory cannot be determined, then no substitution is performed.
    */
    public static let tilde: GlobFlags = GlobFlags(rawValue: GLOB_TILDE)
    /** This provides behavior similar to that of tilde. The difference is
    * that if the username is invalid, or the home directory cannot be
    * determined, then instead of using the pattern itself as the name, glob()
    * throws GlobError.noMatches to indicate an error.
    */
    public static let tildeCheck: GlobFlags = GlobFlags(rawValue: GLOB_TILDE_CHECK)
    /** This is a hint to glob() that the caller is interested only in
    * directories that match the pattern. If the implementation can easily
    * determine file-type information, then nondirectory files are not returned
    * to the caller. However, the caller must still check that returned files
    * are directories. (The purpose of this flag is merely to optimize
    * performance when the caller is interested only in directories.)
    */
    public static let onlyDirectories: GlobFlags = GlobFlags(rawValue: GLOB_ONLYDIR)

    public init(rawValue: IntegerLiteralType) {
        self.rawValue = rawValue
    }

    public init(_ flags: GlobFlags...) {
        rawValue = flags.reduce(0, { $0 | $1.rawValue })
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: value)
    }
}

extension GlobFlags: CustomStringConvertible {
    public var description: String {
        var flags: [String] = []

        if contains(.error) {
            flags.append("error")
        }
        if contains(.unsorted) {
            flags.append("unsorted")
        }
        if contains(.offset) {
            flags.append("offset")
        }
        if contains(.noCheck) {
            flags.append("noCheck")
        }
        if contains(.append) {
            flags.append("append")
        }
        if contains(.noEscape) {
            flags.append("noEscape")
        }
        if contains(.period) {
            flags.append("period")
        }
        if contains(.alternativeDirectoryFunctions) {
            flags.append("alternativeDirectoryFunctions")
        }
        if contains(.brace) {
            flags.append("brace")
        }
        if contains(.noMagic) {
            flags.append("noMagic")
        }
        if contains(.tilde) {
            flags.append("tilde")
        }
        if contains(.tildeCheck) {
            flags.append("tildeCheck")
        }
        if contains(.onlyDirectories) {
            flags.append("onlyDirectories")
        }

        if flags.isEmpty {
            flags.append("none")
        }

        return "\(type(of: self))(\(flags.joined(separator: ", ")), rawValue: \(rawValue))"
    }
}
