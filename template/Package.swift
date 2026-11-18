// swift-tools-version: 6.0
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Furcenzo

import PackageDescription

let package = Package(
    name: "__EXECUTABLE__",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "__EXECUTABLE__", targets: ["__EXECUTABLE__"]),
    ],
    targets: [
        // Pure logic – no UI, tested.
        .target(name: "__CORE__"),
        .executableTarget(
            name: "__EXECUTABLE__",
            dependencies: ["__CORE__"],
            // Localizable.strings files are copied into the .app by scripts/build-app.sh
            exclude: ["Resources"]
        ),
        .testTarget(name: "__CORE__Tests", dependencies: ["__CORE__"]),
    ]
)
