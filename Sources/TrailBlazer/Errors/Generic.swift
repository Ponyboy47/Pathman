import let Cglob.GLOB_ABORTED
import let Cglob.GLOB_NOMATCH
import let Cglob.GLOB_NOSPACE

/// Errors thrown by globbing (see glob(3))
public enum GlobError: Error {
    public typealias ErrorHandler = (@convention(c) (UnsafePointer<CChar>?, OptionInt) -> OptionInt)
    case unknown
    case outOfMemory
    case readError
    case noMatches

    public static func getError(_ returnVal: OptionInt) -> GlobError {
        if returnVal == GLOB_NOSPACE {
            return .outOfMemory
        } else if returnVal == GLOB_ABORTED {
            return .readError
        } else if returnVal == GLOB_NOMATCH {
            return .noMatches
        }

        return .unknown
    }
}

/// Errors thrown during String conversions from Data
public enum StringError: Error {
    case notConvertibleToData(using: String.Encoding)
}

public enum CodingError: Error {
    case incorrectPathType
    case unknownPathType
}

public enum CopyError: Error {
    case uncopyablePath(GenericPath)
    case nonEmptyDirectory
    case pathDoesNotExist
}

public enum AddressError: Error {
    case invalidDomain
}

public enum LocalAddressError: Error {
    case pathnameTooLong
}

public enum SocketTypeError: Error {
    case connectionTypeRequired
}

public enum ClosedDescriptorError: Error {
    case doubleClose
    case alreadyClosed
}
