# PlaceholderModule

<!-- template:start -->
> **Template.** A PowerShell module project built with
> [ModuleBuilder](https://github.com/PoshCode/ModuleBuilder) and
> [InvokeBuild](https://github.com/nightroman/Invoke-Build), its dependencies installed by
> [PSDepend](https://github.com/RamblingCookieMonster/PSDepend), versioned by
> [GitVersion](https://gitversion.net), tested with [Pester](https://pester.dev) 6 on Windows
> PowerShell 5.1 and PowerShell 7, and published to the PowerShell Gallery when a `vX.Y.Z` tag is
> pushed.
>
> To start a module from it:
>
> 1. **Use this template → Create a new repository**, named for the module, and clone it.
> 2. From the clone, run
>    `./Initialize-Project.ps1 -Description 'What the module does.' -Tag Some, Tags`.
>    It replaces `PlaceholderModule` everywhere with the repository's name (or `-Name`), sets the
>    manifest's description and tags, removes the example `Get-Greeting` function and its tests (unless
>    `-KeepExample`), removes this note and deletes itself.
> 3. Review with `git status`, commit, and push. CI runs on the push.
> 4. Before the first release, add a PowerShell Gallery API key as the `NUGET_API_KEY` repository
>    secret.
<!-- template:end -->

## Installation

```powershell
Install-Module -Name PlaceholderModule -Scope CurrentUser
```

## Building

The module source lives in `source/`, one function per file under `Public/` and `Private/`.
ModuleBuilder combines them into a single `.psm1` in `build/PlaceholderModule/<version>/` and fills
in the exported functions and aliases from `Public/`. `source/prefix.ps1` runs ahead of every
function when the module loads. Tests are in `source/tests/` and run against the built module, so
what is tested is what ships.

```powershell
# First time: install the build dependencies into build/modules
./build.ps1 -ResolveDependency -Task Noop

# Build at 0.0.0 and run some or all of the tests, without coverage
./build.ps1 -Task QuickTest -TestPath ./source/tests/public
./build.ps1 -Task QuickTest

# Lint, build at the GitVersion version, and run every test with coverage
./build.ps1
```

| Task | What it does |
| --- | --- |
| `.` (default) | `Clean`, `Analyze`, `Build`, `Test` |
| `Analyze` | PSScriptAnalyzer over `source/Public`, `source/Private` and `prefix.ps1`; on PowerShell 7 beside Windows PowerShell, also checks 5.1 can parse every script |
| `Build` | Builds at the version GitVersion derives (needs `gitversion` on `PATH`) |
| `DevBuild` | Builds at `0.0.0`, no GitVersion needed |
| `Test` | Runs every test against the built module, with code coverage and NUnit results in `build/` |
| `QuickTest` | `DevBuild`, then the tests in `-TestPath` (or all of them), without coverage |
| `Defects` | `DevBuild`, then only the tests tagged `KnownDefect` |
| `Publish` | Publishes the built module to the PowerShell Gallery, using `-NuGetApiKey` or `$env:NuGetApiKey` |

The manifest in `source/` keeps `ModuleVersion` at `0.0.0` and its export lists empty; the build
sets both. A test tagged `KnownDefect` describes a defect not yet fixed: it is left out of every
task but `Defects`, so a clean run means no regressions rather than no known problems.

### Releasing

CI (`.github/workflows/ci.yml`) runs `Build` and `Test` on Windows PowerShell 5.1 and PowerShell 7,
and `Analyze` on 7, for every push and pull request to `main`.

To release, tag `main` with the version and push the tag:

```powershell
git tag v0.1.0
git push origin v0.1.0
```

`.github/workflows/release.yml` then builds, tests, checks that the tag matches the version
GitVersion derives, publishes to the PowerShell Gallery, and creates a GitHub release with
generated notes. GitVersion's `next-version` in `GitVersion.yml` sets the version until the first
tag exists.

## License

[MIT](LICENSE)
