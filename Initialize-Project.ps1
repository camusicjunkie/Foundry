<#
.SYNOPSIS
    Turns a fresh copy of the template into a named module project.

.DESCRIPTION
    Run once, from the root of a repository created from the template. Replaces the
    PlaceholderModule placeholder in every file and file name, gives the manifest a new GUID and its
    description and tags, then deletes this script. Commit the result.

.EXAMPLE
    ./Initialize-Project.ps1 -Description 'Finds the true last logon of Active Directory accounts.' -Tag ActiveDirectory, AD

    Names the module after the repository folder.

.EXAMPLE
    ./Initialize-Project.ps1 -Name Kovacs -Description 'Sleeves and stacks.' -KeepExample

    Names the module Kovacs and keeps the example Get-Greeting function and its tests.
#>
[CmdletBinding(SupportsShouldProcess, PositionalBinding = $false)]
param (
    # The module name; the repository folder's name when not given
    [ValidatePattern('^[A-Za-z][A-Za-z0-9._-]*$')]
    [string] $Name = (Split-Path -Path $PSScriptRoot -Leaf),

    # The manifest's description, shown on the PowerShell Gallery
    [Parameter(Mandatory)]
    [string] $Description,

    # The manifest's Gallery tags
    [string[]] $Tag = @(),

    # Keep the example Get-Greeting function and its tests
    [switch] $KeepExample
)

$ErrorActionPreference = 'Stop'
$placeholder = 'PlaceholderModule'

if ($Name -eq $placeholder) {
    throw "Name the module: -Name, or a repository folder not called $placeholder."
}

# Every tracked text file except this one; git ls-files skips build/ and .git
$files = (git -C $PSScriptRoot ls-files) |
    Where-Object { $_ -ne 'Initialize-Project.ps1' } |
    ForEach-Object { Join-Path $PSScriptRoot $_ }

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file)
    if ($content -cmatch $placeholder -and $PSCmdlet.ShouldProcess($file, "Replace $placeholder with $Name")) {
        # WriteAllText writes UTF-8 without a BOM on both engines, as the files were checked in
        [System.IO.File]::WriteAllText($file, ($content -creplace $placeholder, $Name))
    }
}

$manifestPath = Join-Path $PSScriptRoot "source/$placeholder.psd1"
if ($PSCmdlet.ShouldProcess($manifestPath, 'Set the GUID, description and tags')) {
    $tagList = if ($Tag) { ($Tag | ForEach-Object { "'$($_ -replace "'", "''")'" }) -join ', ' } else { '@()' }

    $manifest = [System.IO.File]::ReadAllText($manifestPath)
    $manifest = $manifest -replace '00000000-0000-0000-0000-000000000000', [guid]::NewGuid()
    $manifest = $manifest -replace "'ModuleDescription'", "'$($Description -replace "'", "''")'"
    $manifest = $manifest -replace 'Tags(\s+)= @\(\)', "Tags`$1= $tagList"
    [System.IO.File]::WriteAllText($manifestPath, $manifest)
}

foreach ($file in "source/$placeholder.psd1", "$placeholder.build.ps1", "$placeholder.depend.psd1") {
    # Only the leaf carries the placeholder, so replacing it in the whole relative path is safe
    $newFile = $file -creplace $placeholder, $Name
    if ($PSCmdlet.ShouldProcess($file, "Rename to $newFile")) {
        git -C $PSScriptRoot mv $file $newFile
    }
}

if (-not $KeepExample) {
    $example = 'source/Public/Get-Greeting.ps1', 'source/Private/Format-Greeting.ps1',
        'source/tests/public/Get-Greeting.Tests.ps1', 'source/tests/private/Format-Greeting.Tests.ps1'
    foreach ($file in $example) {
        if ($PSCmdlet.ShouldProcess($file, 'Remove the example')) {
            git -C $PSScriptRoot rm --quiet --force $file
        }
    }

    # git drops a folder with its last file; the build expects Public and Private to exist
    foreach ($folder in 'source/Public', 'source/Private', 'source/tests/public', 'source/tests/private') {
        $keep = Join-Path $PSScriptRoot "$folder/.gitkeep"
        if (-not (Test-Path (Join-Path $PSScriptRoot $folder))) {
            $null = New-Item -Path $keep -ItemType File -Force
            git -C $PSScriptRoot add $keep
        }
    }

    $prefix = Join-Path $PSScriptRoot 'source/prefix.ps1'
    $prefixContent = [System.IO.File]::ReadAllText($prefix) -replace "(?m)^\`$script:GreetingFormat.*\r?\n?"
    [System.IO.File]::WriteAllText($prefix, $prefixContent)
}

$readme = Join-Path $PSScriptRoot 'README.md'
if ($PSCmdlet.ShouldProcess($readme, 'Remove the template note')) {
    $readmeContent = [System.IO.File]::ReadAllText($readme) -replace '(?s)<!-- template:start -->.*?<!-- template:end -->\r?\n\r?\n?'
    [System.IO.File]::WriteAllText($readme, $readmeContent)
}

if ($PSCmdlet.ShouldProcess($PSCommandPath, 'Remove this script')) {
    git -C $PSScriptRoot rm --quiet --force (Split-Path -Path $PSCommandPath -Leaf)
}

Write-Host "Initialized $Name. Review with 'git status', then commit."
