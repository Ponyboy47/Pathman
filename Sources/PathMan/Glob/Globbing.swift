import Cglob

/// The C globbing function
let cGlob = Cglob.glob
/// The C function for freeing a glob struct
public let cGlobFree = Cglob.globfree

/// A reusable Glob struct
private var globalGlob = Glob()

/** Locates all paths matching the pattern specified

 - Parameter pattern: The path string and glob pattern to use for finding paths
 - Parameter flags: Glob flags to customize the globbing behavior (see GlobFlags)
 - Parameter errorClosure: A closure used if a path in the glob causes an error. Returning a nonZero integer will cause
             the glob function to throw an error
 - Returns: A Glob object that contains the paths matching the pattern as well as other information about the glob

 - Throws: `GlobError.outOfMemory` when there is not enough space to store the results in the glob object
 - Throws: `GlobError.readError` when an error occurred while reading a directory
 - Throws: `GlobError.noMatches` when there were no matches found. Using the `.noCheck` flag will prevent this error
           from being thrown.
 - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
 - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
 - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
 - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
 - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
 - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This
           should only occur if your DirectoryPath object was created before the path existed and then the path was
           created as a non-directory path type
 */
public func glob(pattern: String, flags: GlobFlags = [], errorClosure: GlobError.ErrorHandler? = nil) throws -> Glob {
    try glob(pattern: pattern, flags: flags, errorClosure: errorClosure, glob: &globalGlob)
    return globalGlob
}

/** Locates all paths matching the pattern specified

 - Parameter pattern: The path string and glob pattern to use for finding paths
 - Parameter flags: Glob flags to customize the globbing behavior (see GlobFlags)
 - Parameter errorClosure: A closure used if a path in the glob causes an error. Returning a nonZero integer will cause
             the glob function to throw an error
 - Parameter glob: The glob object into which the glob results are stored

 - Throws: `GlobError.outOfMemory` when there is not enough space to store the results in the glob object
 - Throws: `GlobError.readError` when an error occurred while reading a directory
 - Throws: `GlobError.noMatches` when there were no matches found. Using the `.noCheck` flag will prevent this error
           from being thrown.
 - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
 - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file descriptors
 - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file descriptors
 - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
 - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
 - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory. This
           should only occur if your DirectoryPath object was created before the path existed and then the path was
           created as a non-directory path type
 */
public func glob(pattern: String, flags: GlobFlags = [],
                 errorClosure: GlobError.ErrorHandler? = nil,
                 glob: inout Glob) throws {
    let globResult = cGlob(pattern, flags.rawValue, errorClosure, glob._glob)
    guard globResult == 0 else {
        do {
            throw GlobError.getError(globResult)
            // There may be an error thrown from the underlying opendir/malloc
            // calls, so if it's an unknown GlobError try throwing the
            // OpenDirectoryError (malloc errors hopefully won't ever happen)
        } catch GlobError.unknown {
            throw OpenDirectoryError.getError()
        }
    }
}

public extension DirectoryPath {
    /** Locates all paths matching the pattern specified using this DirectoryPath as the base directory for the glob

     - Parameter pattern: The glob pattern to use for finding paths
     - Parameter flags: Glob flags to customize the globbing behavior (see GlobFlags)
     - Parameter errorClosure: A closure used if a path in the glob causes an error. Returning a nonZero integer will
                 cause the glob function to throw an error
     - Returns: A Glob object that contains the paths matching the pattern as well as other information about the glob

     - Throws: `GlobError.outOfMemory` when there is not enough space to store the results in the glob object
     - Throws: `GlobError.readError` when an error occurred while reading a directory
     - Throws: `GlobError.noMatches` when there were no matches found. Using the `.noCheck` flag will prevent this error
               from being thrown.
     - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
     - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file
               descriptors
     - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file
               descriptors
     - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
     - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
     - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory.
               This should only occur if your DirectoryPath object was created before the path existed and then the path
               was created as a non-directory path type
     */
    func glob(pattern: String,
              flags: GlobFlags = [],
              errorClosure: GlobError.ErrorHandler? = nil) throws -> Glob {
        return try PathMan.glob(pattern: (self + pattern).string, flags: flags, errorClosure: errorClosure)
    }

    /** Locates all paths matching the pattern specified using this DirectoryPath as the base directory for the glob

     - Parameter pattern: The glob pattern to use for finding paths
     - Parameter flags: Glob flags to customize the globbing behavior (see GlobFlags)
     - Parameter errorClosure: A closure used if a path in the glob causes an error. Returning a nonZero integer will
                 cause the glob function to throw an error
     - Parameter glob: The glob object into which the glob results are stored

     - Throws: `GlobError.outOfMemory` when there is not enough space to store the results in the glob object
     - Throws: `GlobError.readError` when an error occurred while reading a directory
     - Throws: `GlobError.noMatches` when there were no matches found. Using the `.noCheck` flag will prevent this error
               from being thrown.
     - Throws: `OpenDirectoryError.permissionDenied` when the calling process does not have access to the path
     - Throws: `OpenDirectoryError.noProcessFileDescriptors` when the process has used all of its available file
               descriptors
     - Throws: `OpenDirectoryError.noSystemFileDescriptors` when the entire system has run out of available file
               descriptors
     - Throws: `OpenDirectoryError.pathDoesNotExist` when the path does not exist
     - Throws: `OpenDirectoryError.outOfMemory` when there is not enough available memory to open the directory
     - Throws: `OpenDirectoryError.pathNotDirectory` when the path you're trying to open exists and is not a directory.
               This should only occur if your DirectoryPath object was created before the path existed and then the path
               was created as a non-directory path type
     */
    func glob(pattern: String,
              flags: GlobFlags = [],
              errorClosure: GlobError.ErrorHandler? = nil,
              glob: inout Glob) throws {
        try PathMan.glob(pattern: (self + pattern).string, flags: flags, errorClosure: errorClosure, glob: &glob)
    }
}
