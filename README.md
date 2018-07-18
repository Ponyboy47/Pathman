# TrailBlazer

A type-safe file path library for Apple's Swift language.

I hate going through Foundation's FileManager. I find it to be an ugly API with inconsistent results when used cross platform (Linux support/stability is important to most of the things I use Swift for), and it lacks the type-safety and ease-of-use that most Swift API's are expected to have. So I built TrailBlazer! The first type-safe swift path library built around the lower level C API's (everything else out there is really just a wrapper around Foundation's FileManager).

## Goals
- Type safety
  - File paths are different that directory paths
- Extensibility
  - Everything is based around protocols so that others could create new path types (ie: socket files)
- Error Handling
  - There are an extensive number of errors so that when something goes wrong you can get the most relevant error message possible
- Minimal Foundation
  - I avoid using Foundation as much as possible, because it is not as stable on Linux as it is on Apple platforms
  - Currently, I only use Foundation for the Data and Date types

## Installation (SPM)
Add this to your Package.swift dependencies:
```swift
.package(url: "https://github.com/Ponyboy47/Trailblazer.git", from: "0.4.0")
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
    print("Path is not a file")
    return
}
// succeeds
guard let directory = DirectoryPath("/tmp") else {
    print("Path is not a directory")
    return
}
```

### Path Information
```swift
// Paths conform to the StatDelegate protocol, which means that they use the
// `stat` utility to gather information about the file (ie: size, ownership,
// modify time, etc)
// NOTE: Only paths that exist will have information about them

/// The system id of the path
path.id

/// The inode of the path
path.inode

/// The type of the file
path.type

/// The permissions of the file
path.permissions

/// The user id of the user that owns the file
path.owner

/// The group id of the user that owns the file
path.group

/// The device id (if special file)
path.device

/// The total size, in bytes
path.size

/// The blocksize for filesystem I/O
path.blockSize

/// The number of 512B block allocated
path.blocks

/// The last time the file was accessed
path.lastAccess

/// The last time the file was modified
path.lastModified

/// The last time the file had a status change
path.lastAttributeChange
```

### Opening Paths

#### FilePaths:
```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

let openFile: OpenFile = try file.open(permissions: .read)
```

#### DirectoryPaths:
```swift
guard let dir = DirectoryPath("/tmp") else {
    fatalError("Path is not a directory")
}

let openDir: OpenDirectory = try dir.open()
```

### Creating Paths

This is the same for all paths. Just replace File with Directory to create a directory instead.
```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

let openFile: OpenFile = try file.create(mode: FileMode(owner: .readWriteExecute, group: .readWrite, other: .none))
```

### Deleting Paths

This is the same for all paths
```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

try file.delete()
```

Recursively delete Directories:
```swift
guard let dir = DirectoryPath("/tmp/test") else {
    fatalError("Path is not a directory")
}

try dir.recursiveDelete()
```
NOTE: Be VERY cautious with this as it cannot be undone.

### Reading Files

```swift
guard let file = FilePath("/tmp/test") else {
    fatalError("Path is not a file")
}

// Read the whole file
let contents: String = file.read()

// Read 1024 bytes
let contents: String = file.read(bytes: 1024)

// Read content as ascii characters instead of utf8
let contents: String = file.read(encoding: .ascii)

// Read to the end, but starting at 1024 bytes from the beginning of the file
let contents: String = file.read(from: Offset(from: .beginning, bytes: 1024))

// Read 64 bytes starting at 1024 bytes from the end using the ascii encoding
let contents: String = file.read(from: Offset(from: .end, bytes: 1024), bytes: 64, encoding: .ascii)
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

// Write a string at the current file position
file.write("Hello world")

// Write an ascii string at the end of the file
file.write("Goodbye", at: Offset(from: .end, bytes: 0), using: .ascii)
```
NOTE: You can also pass a `Data` instance to the write function instead of a String and an encoding.


### Getting Directory Contents:

Immediate children:
```swift
guard let dir = DirectoryPath("/tmp") else {
    fatalError("Path is not a directiry")
}

let children = try dir.children()

// This same operation is safe, assuming you've already opened the directory
let openDir = try dir.open()
let children = openDir.children()
```

Recursive Children:
```swift
guard let dir = DirectoryPath("/tmp") else {
    fatalError("Path is not a directiry")
}

let children = try dir.recursiveChildren()

// This operation is still unsafe, even if the directory is already opened (Because you still might have to open sub-directories, which is unsafe)
let openDir = try dir.open()
let children = try openDir.recursiveChildren()

// You can optionally specify a depth to only get so many directories
// This will go no more than 5 directories deep before returning
let children = try dir.recursiveChildren(depth: 5)
```

Hidden Files:
```swift
// Both .children() and .recursiveChildren() support getting hidden files/directories (files that begin with a '.')
let children = try dir.children(includeHidden: true)
let children = try dir.recursiveChildren(depth: 5, includeHidden: true)
```

## To Do
- FilePath
  - [x] Create new files
- DirectoryPath
  - [x] Get directory contents
  - [x] Get directory contents recursively
  - [x] Create new directories
  - [x] Delete directories
  - [x] Recursively delete directory
- GenericPath (AKA all Paths)
  - [x] Change path ownership
  - [ ] Change path permissions
  - [ ] Move paths
  - [ ] Rename paths (move alias)
- Misc. Additions
  - [ ] Globbing
  - [ ] LinkedPath (symlinks)
  - [ ] SocketPath
  - [ ] FIFOPath?
  - [ ] BlockPath?
  - [ ] CharacterPath?
