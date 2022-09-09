// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SPMLicenseGen",
    products: [
        .plugin(
            name: "GenerateLicensesPlugin",
            targets: ["GenerateLicensesPlugin"])
    ],
    targets: [
        .plugin(
            name: "GenerateLicensesPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "GenerateLicensesExec")
            ]),
        .executableTarget(
            name: "GenerateLicensesExec")
    ]
)
