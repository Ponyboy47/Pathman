# Pathman

[![Build Status](https://travis-ci.org/Ponyboy47/Pathman.svg?branch=master)](https://travis-ci.org/Ponyboy47/Pathman) [![codecov](https://codecov.io/gh/Ponyboy47/Pathman/branch/master/graph/badge.svg)](https://codecov.io/gh/Ponyboy47/Pathman) [![Maintainability](https://api.codeclimate.com/v1/badges/4bafeb6b0d65f0c57fa6/maintainability)](https://codeclimate.com/github/Ponyboy47/Pathman/maintainability) [![Current Version](https://img.shields.io/badge/version-0.18.0-blue.svg)](https://github.com/Ponyboy47/Pathman/releases/tag/0.18.0) ![Supported Platforms](https://img.shields.io/badge/platform-macOS%20%7C%20linux-lightgrey.svg) [![Language](https://img.shields.io/badge/language-swift-orange.svg)](https://swift.org) [![Language Version](https://img.shields.io/badge/swift%20version-5.0-blue.svg)](https://swift.org/download/) [![License](https://img.shields.io/badge/license-MIT-black.svg)](https://github.com/Ponyboy47/Pathman/blob/master/LICENSE)<br>
A type-safe path library for Apple's Swift language.

## Motivation
I have never been a big fan of Foundation's `FileManager`. Foundation in general has inconsistent results when used cross-platform (Linux support/stability is important for most of the things for which I use Swift) and `FileManager` itself lacks the type-safety and ease-of-use that most Swift API's are expected to have (`FileAttributeKey` anyone?).

So I built Pathman! The first type-safe swift path library built around the lower level C API's (everything else out there is just a wrapper around `FileManager` to make it nicer to use in Swift).

## Goals
- Type safety
  - File paths are different that directory paths and should be treated as such
- Extensibility
  - Everything is based around protocols or extensible classes so that others can create new path types (ie: sockets)
- Error Handling
  - There are an extensive number of errors so that when something goes wrong you can get the most relevant error message possible (see Errors.swift)
    - No more dealing with obscure `NSError`s when `FileManager` throws
- Minimal Foundation
  - I avoid using Foundation as much as possible, because it is not as stable on Linux as it is on Apple platforms (yet) and the results for some APIs are inconsistent between Linux and macOS
  - Currently, I only use Foundation for the `Data`, `Date`, and `URL` types
- Ease of Use
  - No clunky interface just to get attributes of a path
    - Was anyone ever a fan of `FileAttributeKey`s?
- Expose low-level control with high-level safety built-in

## Installation
### Compatibility:
- Swift 5.0
- Ubuntu
- macOS

### Swift Package Manager:
Add this to your Package.swift dependencies:
```swift
.package(url: "https://github.com/Ponyboy47/Pathman.git", from: "0.18.0")
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
// NOTE: Certain properties are only available for paths that exist

/// The system id of the path
var id: DeviceID

/// The inode of the path
var inode: Inode

/// The type of the path, if it exists
var type: PathType

/// Whether the path exists
var exists: Bool

/// Whether the path exists and is a file
var isFile: Bool

/// Whether the path exists and is a directory
var isDirectory: Bool

/// Whether the path exists and is a link
var isLink: Bool

/// The URL representation of the path
var url: URL

/// The permissions of the path
var permissions: FileMode

/// The user id of the user that owns the path
var owner: UID

// The name of the user that owns the path
var ownerName: String?

/// The group id of the user that owns the path
var group: GID

/// The name of the group that owns the path
var groupName: String?

/// The device id (if special file)
var device: DeviceID

/// The total size, in bytes
var size: OSOffsetInt
// macOS -> Int64
// Linux -> Int

/// The blocksize for filesystem I/O
var blockSize: BlockSize

/// The number of 512B block allocated
var blocks: OSOffsetInt
// macOS -> Int64
// Linux -> Int

/// The parent directory of the path
var parent: DirectoryPath

/// The pieces that make up the path
var components: [String]

/// The final piece of the path (filename or directory name)
var lastComponent: String?

/// The final piece of the path with the extension stripped off
var lastComponentWithoutExtension: String?

/// The extension of the path
var extension: String?

/// The last time the path was accessed
var lastAccess: Date

/// The last time the path was modified
var lastModified: Date

/// The last time the path had a status change
var lastAttributeChange: Date

/// The time when the path was created (macOS only)
var creation: Date
```

### Opening Paths

#### FilePath:
```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

let openFile: OpenFile = try file.open(mode: "r+")

// Open files can be written to or read from (depending on the permissions used above)
let content: String = try openFile.read()
try openFile.write(content)
```

#### DirectoryPath:
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

#### With Closure:

Paths may also be opened for the duration of a provided closure:
```swift
guard let dir = DirectoryPath("/tmp") else {
    fatalError("Path is not a directory")
}

try dir.open() { openDirectory in
    let children = openDirectory.children()
    print(children)
}
```

### Creating Paths

#### Any Path conforming to Openable:
```swift
guard var file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

// Creates a file with the write permissions and returns the opened file
let openFile: OpenFile = try file.create(mode: FileMode(owner: .readWriteExecute, group: .readWrite, other: .none))
```

#### Creating Intermediate Directories:

In the event you need to create the intermediate paths as well:
```swift
guard var file = FilePath("/tmp/testdir/test") else {
    fatalError("Path is not a file")
}

let openFile: OpenFile = try file.create(options: .createIntermediates)
```

#### With Contents:

Paths whose Open<...> variation conforms to Writable can be created with predetermined contents:
```swift
guard var file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

try file.create(contents: "Hello World")
print(try file.read()) // "Hello World"
```

#### With Closure:

Paths may also be opened for the duration of a provided closure:
```swift
guard var file = FilePath("/tmp/test") else {
    fatalError("Path already exists and is not a file")
}

try file.create() { openFile in
    try openFile.write("Hello world")
    let contents: String = try openFile.read(from: .beginning)
    print(contents) // Hello World
}
```

### Deleting Paths

#### The current path only:
This is the same for all paths
```swift
guard var file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

try file.delete()
```

#### Recursively delete directories:
```swift
guard var dir = DirectoryPath("/tmp/test") else {
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

// All of the following operations are available on both a FilePath and an OpenFile

// Read the whole file
let contents: String = try file.read()

// Read up to 1024 bytes
let contents: String = try file.read(bytes: 1024)

// Read content as ascii characters instead of utf8
let contents: String = try file.read(encoding: .ascii)

// Read to the end, but starting at 1024 bytes from the beginning of the file
let contents: String = try file.read(from: Offset(from: .beginning, bytes: 1024))

// Read the last 1024 bytes from of the file using the ascii encoding
let contents: String = try file.read(from: Offset(from: .end, bytes: -1024), bytes: 1024, encoding: .ascii)
```

NOTES:<br />
Reading from a `FilePath` is only intended to be used when performing a single read operation on a file since it will open the file, read from the file, and close the file. If you're going to read a file multiple times, then it would be best to open it (with `try file.open(permissions: .read)` and then read it as much as you want.<br />
The file offset is updated after each read. If you wish to read from the beginning again then pass an offset of `Offset(from: .beginning, bytes: 0)`.<br />
If the file was opened using the `.append` flag then any offsets passed will be ignored and the file offset is moved to the end of the file before any write operations.<br />
Each of the read operations may either return `String` or  `Data`, so be sure the object you're storing into is explicitly typed, otherwise, you will have an ambiguous use-case.

### Writing Files

```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

// All of the following operations are available on both a FilePath and an OpenFile

// Write a string at the current file position
try file.write("Hello world")

// Write an ascii string at the end of the file
try file.write("Goodbye", at: Offset(from: .end, bytes: 0), using: .ascii)
```
NOTE: You can also pass a `Data` instance to the write function instead of a `String` with an encoding.

### Buffered File Writing

```
// Writing files is buffered by default. If you expect to use a file
// immediately after writing to it then be sure to flush the buffer
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

let openFile = try file.open(mode: "w+")
try openFile.write("Hello world!")
try openFile.flush()
try openFile.rewind()
let contents = openFile.read()

// You may also change the buffering mode for the file
try openFile.setBuffer(mode: .line) // Flushes after each newline
try openFile.setBuffer(mode: .none) // Flushes immediately
try openFile.setBuffer(mode: .full(size: 1024)) // Flushes after 1024 bytes are written
```
NOTE: The default buffering is full buffering based on your OS's `BUFSIZ` variable


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
var path = GenericPath("/tmp")

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
guard var dir = DirectoryPath(path) else {
    fatalError("Path is not a directory")
}

try dir.recursiveChange(owner: "ponyboy47")
```

#### Permissions:
```swift
var path = GenericPath("/tmp")

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
guard var dir = DirectoryPath(path) else {
    fatalError("Path is not a directory")
}

try dir.recursiveChange(owner: .readWriteExecute, group: .readWrite, others: .read)
```

### Moving Paths:

```swift
var path = GenericPath("/tmp/testFile")

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

#### Creating Temporary Paths:
```swift
let tmpFile = try FilePath.temporary()
// /tmp/vDjKM1C

let tmpDir = try DirectoryPath.temporary()
// /tmp/rYcznHQ

// You can optionally specify a prefix for the path name
let tmpFile = try FilePath.temporary(prefix: "com.pathman.")
// /tmp/com.pathman.gHyiZq

// You can optionally specify a base directory where the temporary path will be stored
let tmpDirectory = try DirectoryPath.temporary(base: DirectoryPath("/path/to/my/tmp")!, prefix: "com.pathman.")
// /path/to/my/tmp/com.pathman.2eH4iB
```

#### With Closure:
```swift
// When creating a temporary path with a closure, the path of the temporary
// file is returned instead of an Opened path
let tmpFile: FilePath = try FilePath.temporary() { openFile in
    try openFile.write("Hello World")
}

// You can also pass the .deleteOnCompletion option to the .temporary()
// function in order to delete the temporary path after the closure exits
// NOTE: This will recursively delete the temporary path if it is a DirectoryPath
try FilePath.temporary(options: .deleteOnCompletion) { openFile in
    try openFile.write("Hello World")
}
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

Pathman uses .symbolic/.soft links as the default, but this may be changed.
```swift
Pathman.defaultLinkType = .hard
```

### Copy Paths:

#### FilePath:
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

#### DirectoryPath:
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
