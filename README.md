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
.package(url: "https://github.com/Ponyboy47/Trailblazer.git", from: "0.1.0")
```

## Usage

There are 3 different Path types right now:
GenericPath, FilePath, and DirectoryPath
```swift
// Paths can be initialized from Strings, Arrays, or Slices
let genericString = GenericPath("/tmp")
let genericArray = GenericPath(["/", "tmp"])
let genericSlice = GenericPath(["/", "tmp", "test"].dropLast())

// FilePaths and DirectoryPaths can be initialized the same as a GenericPath, but their initializers
// are failable.
// The initializers will fail if the path exists and does not match the expected type. If the path 
// does not exist, then the object will be created successfully

// fails
let file = FilePath("/tmp") else {
    print("Path is not a file")
    return
}
// succeeds
guard let directory = DirectoryPath("/tmp") else {
    print("Path is not a directory")
    return
}
```

Getting information about a path:
```swift
// Paths conform to the StatDelegate protocol, which means that they use the `stat` utility to gather
// information about the file (ie: size, ownership, modify time, etc)
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

More to come...

## To Do
- FilePath
  - [ ] Create new files
- DirectoryPath
  - [ ] Get directory contents
  - [ ] Create new directories
- GenericPath (AKA all Paths)
  - [ ] Change path ownership
  - [ ] Change path permissions
- Misc. Additions
  - [ ] Globbing
