import PackageDescription

let package = Package(
    name: "RDBCSQLite",
    dependencies: [
        .Package(url: "https://github.com/reactive-swift/RDBC.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/carlbrown/CSQLite.git", majorVersion: 0, minor: 0),
    ]
)
