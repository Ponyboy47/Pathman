# TrailBlazer

[![Build Status](https://travis-ci.org/Ponyboy47/Trailblazer.svg?branch=master)](https://travis-ci.org/Ponyboy47/Trailblazer) ![Supported Platforms](https://img.shields.io/badge/platform-macOS%20%7C%20linux-lightgrey.svg) [![Language](https://img.shields.io/badge/language-swift-orange.svg)](https://swift.org) [![License](https://img.shields.io/badge/license-MIT-black.svg)](https://github.com/Ponyboy47/Trailblazer/blob/master/LICENSE)<br>
A type-safe path library for Apple's Swift language.

## Motivation
I am not a big fan of Foundation's `FileManager`. Foundation in general has inconsistent results when used cross-platform (Linux support/stability is important to most of the things for which I use Swift), and `FileManager` lacks the type-safety and ease-of-use that most Swift API's are expected to have (`FileAttributeKey` anyone?). So I built TrailBlazer! The first type-safe swift path library built around the lower level C API's (everything else out there is really just a wrapper around `FileManager`).

## Goals
- Type safety
  - File paths are different that directory paths and should be treated as such
- Extensibility
  - Everything is based around protocols or extensible classes so that others can create new path types (ie: socket files)
- Error Handling
  - There are an extensive number of errors so that when something goes wrong you can get the most relevant error message possible (see Errors.swift)
    - No more dealing with obscure `NSError`s when `FileManager` throws
- Minimal Foundation
  - I avoid using Foundation as much as possible, because it is not as stable on Linux as it is on Apple platforms and the results for some APIs are inconsistent between Linux and macOS
  - Currently, I only use Foundation for the `Data`, `Date`, and `URL` types
- Ease of Use
  - No clunky interface just to get attributes of a path
    - Was anyone ever a fan of `FileAttributeKey`s?
- Expose low-level control with high-level safety built-in

## Installation
### Compatibility:
- Swift 4.2
- Ubuntu (verified on 16.04 and 18.04)
- macOS (verified on 10.13)

### Swift Package Manager:
Add this to your Package.swift dependencies:
```swift
.package(url: "https://github.com/Ponyboy47/Trailblazer.git", from: "0.11.0")
```

## Usage

### Paths
There are 3 different Path types right now:
GenericPath, FilePath, and DirectoryPath
```swift
// Paths can be initialized from Strings, Arrays, or Slices
let genericString = GenericPath("/tmp")
let genericArray = GenericPath(["/", "tmp"])
let genericSlice = GenericPath(["/", "tmp", "test"].dropLast())

// FilePaths and DirectoryPaths can be initialized the same as a GenericPath,
// but their initializers are failable.

// The initializers will fail if the path exists and does not match the
// expected type. If the path does not exist, then the object will be created
// successfully

// fails
guard let file = FilePath("/tmp") else {
    fatalError("Path is not a file")
}

// succeeds
guard let directory = DirectoryPath("/tmp") else {
    fatalError("Path is not a directory")
}
```

### Path Information
```swift
// Paths conform to the StatDelegate protocol, which means that they use the
// `stat` utility to gather information about the file (ie: size, ownership,
// modify time, etc)
// NOTE: Only paths that exist will have information about them (obviously)

/// The system id of the path
path.id

/// The inode of the path
path.inode

/// The type of the path
path.type

/// The permissions of the path
path.permissions

/// The user id of the user that owns the path
path.owner

/// The group id of the user that owns the path
path.group

/// The device id (if special file)
path.device

/// The total size, in bytes
path.size

/// The blocksize for filesystem I/O
path.blockSize

/// The number of 512B block allocated
path.blocks

/// The last time the path was accessed
path.lastAccess

/// The last time the path was modified
path.lastModified

/// The last time the path had a status change
path.lastAttributeChange

/// The time when the path was created (macOS only)
path.creation
```

### Opening Paths

#### FilePaths:
```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

let openFile: OpenFile = try file.open(permissions: .readWrite)

// Open files can be written to or read from (depending on the permissions used above)
let content: String = try openFile.read()
try openFile.write(content)
```

#### DirectoryPaths:
```swift
guard let dir = DirectoryPath("/tmp") else {
    fatalError("Path is not a directory")
}

let openDir: OpenDirectory = try dir.open()

// Open directories can be traversed
let children = openDir.children()

// Recursively traversing directories requires opening sub-directories and may throw errors
let recursiveChildren = try openDir.recursiveChildren()
```

### Creating Paths

This is the same for all paths
```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

// Creates a file with the write permissions and returns the opened file
let openFile: OpenFile = try file.create(mode: FileMode(owner: .readWriteExecute, group: .readWrite, other: .none))
```

#### Creating Intermediate Directories:

In the event you need to create the intermediate paths as well:
```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

let openFile: OpenFile = try file.create(options: .createIntermediates)
```

### Deleting Paths

#### The current path only:
This is the same for all paths
```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

try file.delete()
```

#### Recursively delete directories:
```swift
guard let dir = DirectoryPath("/tmp/test") else {
    fatalError("Path is not a directory")
}

try dir.recursiveDelete()
```
NOTE: Be VERY cautious with this as it cannot be undone (just like `rm -rf`).

### Reading Files

```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

// Any of the following examples could throw either an `OpenFileError` or a `ReadError`

// Read the whole file
let contents: String = try file.read()

// Read 1024 bytes
let contents: String = try file.read(bytes: 1024)

// Read content as ascii characters instead of utf8
let contents: String = try file.read(encoding: .ascii)

// Read to the end, but starting at 1024 bytes from the beginning of the file
let contents: String = try file.read(from: Offset(from: .beginning, bytes: 1024))

// Read 64 bytes starting at 1024 bytes from the end using the ascii encoding
let contents: String = try file.read(from: Offset(from: .end, bytes: 1024), bytes: 64, encoding: .ascii)
```

NOTES:<br />
The file offset is tracked and updated after each read. If you wish to read from the beginning again then pass an offset of `Offset(from: .beginning, bytes: 0)`.<br />
If the file was opened using the `.append` flag then any offsets passed will be ignored and the file offset is moved to the end of the file before any write operations.<br />
Each of the read operations also has a `Data` based function, so be sure the object you're storing into is explicitly typed with either `Data` or `String`. Otherwise you will have an ambiguous use-case.

### Writing Files

```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

// Any of the following examples could throw either an `OpenFileError` or a `WriteError`

// Write a string at the current file position
try file.write("Hello world")

// Write an ascii string at the end of the file
try file.write("Goodbye", at: Offset(from: .end, bytes: 0), using: .ascii)
```
NOTE: You can also pass a `Data` instance to the write function instead of a String and an encoding.


### Getting Directory Contents:

#### Immediate children:
```swift
guard let dir = DirectoryPath("/tmp") else {
    fatalError("Path is not a directory")
}

let children = try dir.children()

// This same operation is safe, assuming you've already opened the directory
let openDir = try dir.open()
let children = openDir.children()

print(children.files)
print(children.directories)
print(children.other)
```

#### Recursive children:
```swift
guard let dir = DirectoryPath("/tmp") else {
    fatalError("Path is not a directory")
}

let children = try dir.recursiveChildren()

// This operation is still unsafe, even if the directory is already opened (Because you still might have to open sub-directories, which is unsafe)
let openDir = try dir.open()
let children = try openDir.recursiveChildren()

print(children.files)
print(children.directories)
print(children.other)

// You can optionally specify a depth to only get so many directories
// This will go no more than 5 directories deep before returning
let children = try dir.recursiveChildren(depth: 5)
```

#### Hidden Files:
```swift
// Both .children() and .recursiveChildren() support getting hidden files/directories (files that begin with a '.')
let children = try dir.children(options: .includeHidden)
let recursiveChildren = try dir.recursiveChildren(depth: 5, options: .includeHidden)
```

### Changing Path Metadata:

#### Ownership:
```swift
let path = GenericPath("/tmp")

// Owner/Group can be changed separately or together
try path.change(owner: "ponyboy47")
try path.change(group: "ponyboy47")
try path.change(owner: "ponyboy47", group: "ponyboy47")

// You can also set them through the corresponding properties:
// NOTE: Setting them this way is NOT guarenteed to succeed and any errors
// thrown are ignored. If you need a reliant way to set path ownership then you
// should call the `change` method directly
path.owner = 0
path.group = 1000
path.ownerName = "root"
path.groupName = "wheel"

// If you have a DirectoryPath, then changes can be made recursively:
guard let dir = DirectoryPath(path) else {
    fatalError("Path is not a directory")
}

try dir.recursiveChange(owner: "ponyboy47")
```

#### Permissions:
```swift
let path = GenericPath("/tmp")

// Owner/Group/Others permissions can each be changed separately or in any combination (permissions that are not specified are not changed)
try path.change(owner: [.read, .write, .execute]) // Only changes the owner's permissions
try path.change(group: .readWrite) // Only changes the group's permissions
try path.change(others: .none) // Only changes other's permissions
try path.change(ownerGroup: .all) // Only changes owner's and group's permissions
try path.change(groupOthers: .read) // Only changes group's and other's permissions
try path.change(ownerOthers: .writeExecute) // Only changes owner's and other's permissions
try path.change(ownerGroupOthers: .all) // Changes all permissions

// You can also change the uid, gid, and sticky bits
try path.change(bits: .uid)
try path.change(bits: .gid)
try path.change(bits: .sticky)
try path.change(bits: [.uid, .sticky])
try path.change(bits: .all)

// You can also set them through the permissions property:
// NOTE: Setting them this way is NOT guarenteed to succeed and any errors
// thrown are ignored. If you need a reliant way to set path ownership then you
// should call the `change` method directly
path.permissions = FileMode(owner: .readWriteExecute, group: .readWrite, others: .read)
path.permissions.owner = .readWriteExecute
path.permissions.group = .readWrite
path.permissions.others = .read
path.permissions.bits = .none

// If you have a DirectoryPath, then changes can be made recursively:
guard let dir = DirectoryPath(path) else {
    fatalError("Path is not a directory")
}

try dir.recursiveChange(owner: .readWriteExecute, group: .readWrite, others: .read)
```

### Moving Paths:

```swift
let path = GenericPath("/tmp/testFile")

// Both of these things will move testFile from /tmp/testFile to ~/testFile
try path.move(to: DirectoryPath.home! + "testFile")
try path.move(into: DirectoryPath.home!)

// This renames a file in place
try path.rename(to: "newTestFile")
```

### Globbing:

```swift
let globData = try glob(pattern: "/tmp/*")

// Just like getting a directories children:
print(globData.files)
print(globData.directories)
print(globData.other)

// You can also glob from a DirectoryPath
guard let home = DirectoryPath.home else {
    fatalError("Failed to get home directory")
}

let globData = try home.glob("*.swift")

print(globData.files)
print(globData.directories)
print(globData.other)
```

### Temporary Paths:

```swift
let tmpFile = try FilePath.temporary()
// /tmp/vDjKM1C

let tmpDir = try DirectoryPath.temporary()
// /tmp/rYcznHQ

// You can optionally specify a prefix for the path
let tmpFile = try FilePath.temporary(prefix: "com.trailblazer.")
// /tmp/com.trailblazer.gHyiZq

let tmpDirectory = try DirectoryPath.temporary(prefix: "com.trailblazer.")
// /tmp/com.trailblazer.2eH4iB
```

### Links:

#### Target to Destination:
```swift
// You can link to an existing path
guard let dir = DirectoryPath("/tmp") else {
    fatalError("Path not a directory")
}

// Creates a soft/symbolic link to dir at the specified path
// All 3 of the following lines produce the same type of link
let link = try dir.link(at: "~/tmpDir.link")
let link = try dir.link(at: "~/tmpDir.symbolic", type: .symbolic)
let link = try dir.link(at: "~/tmpDir.soft", type: .soft)

// Creates a hard link to dir at the specified path
let link = try dir.link(at: "~/tmpDir.hard", type: .hard)
```

#### Destination from Target:
```swift
guard let linkedFile = FilePath("/path/to/link/location") else {
    fatalError("Path is not a file")
}

// Creates a soft/symbolic link to dir at the specified path
// All 3 of the following lines produce the same type of link
let link = try linkedFile.link(from: "/path/to/link/target")
let link = try linkedFile.link(from: "/path/to/link/target", type: .symbolic)
let link = try linkedFile.link(from: "/path/to/link/target", type: .soft)

// Creates a hard link to dir at the specified path
let link = try linkedFile.link(from: "/path/to/link/target", type: .hard)
```

#### Changing the Default Link Type:

TrailBlazer uses .symbolic/.soft links as the default, but this may be changed.
```swift
TrailBlazer.defaultLinkType = .hard
```

### Copy Paths:

#### FilePaths:
```swift
guard let file = FilePath("/path/to/file") else {
    fatalError("Path is not a file")
}

guard let copyPath = FilePath("/path/to/copy") else {
    fatalError("Path already exists and is not a file")
}

// Both these lines would result in the same thing
try file.copy(to: copyPath)
try file.copy(to: "/path/to/copy")
```

#### DirectoryPaths:
```swift
guard let dir = DirectoryPath("/path/to/directory") else {
    fatalError("Path is not a file")
}

guard let copyPath = DirectoryPath("/path/to/copy") else {
    fatalError("Path already exists and is not a directory")
}

// Both these lines would result in the same thing
try dir.copy(to: copyPath)
try dir.copy(to: "/path/to/copy")

// NOTE: Copying directories will fail if the directory is not empty, so pass
// the recursive option to the copy call in order to sucessfully copy non empty
// directories
try dir.copy(to: copyPath, options: .recursive)

// NOTE: You may also include hidden files with the includeHidden option
try dir.copy(to: copyPath, options: [.recursive, .includeHidden])
```

## To Do
- FilePath
  - [x] Create new files
    - [x] Create intermediate directories
    - [ ] With specified contents
- DirectoryPath
  - [x] Get directory contents
  - [x] Get directory contents recursively
  - [x] Create new directories
    - [x] Create intermediate directories
  - [x] Delete directories
  - [x] Recursively delete directory
- GenericPath (AKA all Paths)
  - [x] Change path ownership
  - [x] Change path permissions
    - [x] Allow octal numeric strings to be used for changing permissions
  - [x] Move paths
  - [x] Rename paths (move alias)
  - [x] URL conversion
  - [x] Get/generate temporary files/directories
  - [x] Copy paths
- Misc. Additions
  - [x] Globbing
  - [x] LinkedPath (symlinks and hard links)
  - [x] Make Paths Codable
  - [ ] TemporaryPaths
    - The path is initialized based on the following options:
      - [ ] Storage: Either deletes itself (and everything in it) once all references to it are gone, or it doesn't
      - [ ] Base: Whether to generate or supply the root temporary directory (/tmp or not)
    - Used by the temporary() API call
    - [ ] Temporary path in closure (deleted afterwards if specified)
  - [ ] APIs for checking permissions to a path
    - [ ] canRead/Write/Execute/Delete == Whether or not the calling process (or specified uid/gid/username/groupname) can read/write/execute/delete the path
    - [ ] mayRead/Write == Whether or not the path was opened with read/write permissions
  - [ ] SocketPath
  - [ ] FIFOPath?
  - [ ] BlockPath?
  - [ ] CharacterPath?
  - [ ] Place deleted items in trash (instead of deleting directly)
  - [ ] Mount/unmount paths
  - [ ] Change CWD/Root for closure only
  - [ ] Pattern matching (~=)
  - [ ] Useful operators (<<, >>, etc)
  - [ ] Consolidate repeated/common errors
  - [ ] Atomic writing (see Data.WritingOptions)
  - [ ] Make sure we support common Data.ReadingOptions
- [ ] Investigate TypeErasure to see if it could benefit Paths and Open objects interact together more nicely
- [ ] Investigate ARC best-practices and see if memory usage/performance/correctness can be improved
  - https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html
- [ ] Investigate improved Hashable conformances
  - https://developer.apple.com/documentation/swift/adopting_common_protocols
- [ ] Study the Ownership Manifesto to see if anything can have improved memory semantics/performance
  - https://github.com/apple/swift/blob/master/docs/OwnershipManifesto.md
- [ ] Investiagte class behaviors and ensure proper COW (or other) copy semantics
  - Don't want to change a LinkedPath and end up changing some GenericPath of a FilePath in a PathCollection...
    - [ ] Slicing/Collection APIs
- [ ] Migrate usage examples to a separate Wiki
  - [ ] Document performance pitfalls
- [ ] Make a FileSystem utility for easily getting some file system attributes
  - [ ] Free/Used bytes
  - [ ] Total size
  - [ ] Type
  - [ ] More?
- [ ] Annotate code with preconditions and assertions
- Investigate Domains
  - https://developer.apple.com/documentation/foundation/filemanager/searchpathdomainmask
    - [ ] User (~)
    - [ ] System (/)
    - [ ] Local (/usr/local)
    - [ ] Network (??)
    - [ ] All
- Investigate Common Search Paths
  - https://developer.apple.com/documentation/foundation/filemanager/searchpathdirectory
- [ ] Awesome logo/icon
- Crazy Stuff
  - [ ] `URLPath`
    - [ ] Separate current `Path` protocol into a `FileSystemPath` sub-protocol (only keeping relevant stuff in `Path`)
    - [ ] Opening a `URLPath` downloads data?
    - [ ] Support relevant standards and common manipulations
