# SPMLicenseGen

A build tool plugin that collects the licenses of the SPM-managed packages in an Xcode project into a property list XML file.

## Usage

1. Add the package to the project. The package product `GenerateLicensesExec` does __not__ need to be added to the target.
2. Add `GenerateLicensesPlugin` to your target at Build Phases -> Run Build Tool Plug-ins.
3. Use the output file, for example:

```
let path = Bundle.main.path(forResource: "Licenses", ofType: "xml"),
let xml = try? Data(contentsOf: URL(fileURLWithPath: path)),
let licenses = try? PropertyListDecoder().decode([String: String].self, from: xml)
```

## Notes

- Uses the checked-out packages in `DerivedData`. Does not make network requests.
- The output file is written to `.../DerivedData/.../SourcePackages/plugins/...output/.../Licenses.xml`, but the generated file is automatically included in the target the build tool plugin is applied to, so no extra steps are required to use it.
- The property list keys follow the package directory name under `.../SourcePackages/checkouts`. In other words, the repository name is used as the "package name" in the output. This may sometimes not exactly match the proper name of the package.

## TODO

- [ ] Add Swift package support (currently only supports Xcode projects)
- [ ] Check if something can be done about `Run script build phase 'Generate licenses' will be run during every build because the option to run the script phase "Based on dependency analysis" is unchecked.`
