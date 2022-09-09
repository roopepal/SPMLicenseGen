//
//  Created by Roope Palomäki on 9.9.2022.
//

import PackagePlugin
import Foundation

@main struct GenerateLicensesPlugin: BuildToolPlugin {

    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) async throws -> [Command] {
        // TODO: Implement execution for Swift packages
        return []
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension GenerateLicensesPlugin: XcodeBuildToolPlugin {

    func createBuildCommands(
        context: XcodePluginContext,
        target: XcodeTarget
    ) throws -> [Command] {

        guard
            let packageResolved = getPackageResolvedPath(context: context),
            let sourcePackages = getSourcePackagesPath(context: context)
        else {
            return []
        }

        let tool = try context.tool(named: "GenerateLicensesExec")
        let outFile = context.pluginWorkDirectory.appending("Licenses.xml")

        return [
            .buildCommand(
                displayName: "Generate licenses",
                executable: tool.path,
                arguments: [packageResolved, sourcePackages, outFile],
                outputFiles: [outFile]
            )
        ]
    }

    private func getSourcePackagesPath(
        context: XcodePluginContext
    ) -> Path? {

        var currentDir = context.pluginWorkDirectory

        while
            !currentDir.string.isEmpty,
            currentDir.lastComponent != "SourcePackages"
        {
            currentDir = currentDir.removingLastComponent()
        }

        return !currentDir.string.isEmpty ? currentDir : nil
    }

    /// Returns the path to the first `Package.resolved` file found
    /// in the project directory of the given context, if any.
    private func getPackageResolvedPath(
        context: XcodePluginContext
    ) -> Path? {

        let projectDir = context.xcodeProject.directory.string

        guard let enumerator = FileManager.default.enumerator(atPath: projectDir) else {
            return nil
        }

        while let path = enumerator.nextObject() as? String {
            if path.hasSuffix("Package.resolved") {
                return Path("\(projectDir)/\(path)")
            }
        }

        return nil
    }
}
#endif
