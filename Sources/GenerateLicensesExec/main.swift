//
//  Created by Roope Palomäki on 9.9.2022.
//

import Foundation

struct PackageResolved: Decodable {
    var pins: [Pin]?

    struct Pin: Decodable {
        var location: String?
    }
}

let arguments = ProcessInfo().arguments

let (packageResolvedPath, sourcePackagesPath, outFilePath) =
    (arguments[1], arguments[2], arguments[3])

let checkoutsPath = "\(sourcePackagesPath)/checkouts"
let packagePaths = try FileManager.default.contentsOfDirectory(atPath: checkoutsPath)

guard let packagesResolvedData = FileManager.default.contents(atPath: packageResolvedPath) else {
    fatalError("Failed to read file at \(packageResolvedPath)")
}

var licenses = [String: String]()

let packagesResolved = try JSONDecoder().decode(PackageResolved.self, from: packagesResolvedData)

func findLicenseFile(atPath path: String) -> Data? {
    for ext in ["", ".md", ".txt"] {
        let licensePath = "\(path)/LICENSE\(ext)"

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: licensePath, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return findLicenseFile(atPath: licensePath)
            }
        }

        if let data = FileManager.default.contents(atPath: licensePath) {
            return data
        }
    }

    return nil
}

for location in packagesResolved.pins?.compactMap({ $0.location }) ?? [] {
    guard let packageDirName = URL(string: location)?.deletingPathExtension().lastPathComponent else {
        continue
    }

    let packagePath = "\(checkoutsPath)/\(packageDirName)"

    if
        let data = findLicenseFile(atPath: packagePath),
        let string = String(data: data, encoding: .utf8)
    {
        licenses[packageDirName] = string
    }
}

let encoder = PropertyListEncoder()
encoder.outputFormat = .xml

let outFileUrlString = "file://\(outFilePath)"
guard let outFileUrl = URL(string: outFileUrlString) else {
    fatalError("Failed to initialize output file URL \(outFileUrlString)")
}

try encoder.encode(licenses).write(to: outFileUrl)
