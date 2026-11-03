function Get-Greeting {
    <#
    .SYNOPSIS
        Greets someone by name.

    .DESCRIPTION
        An example public function, exported because its file is in source/Public. Delete it,
        its private helper and their tests once the module has functions of its own.

    .EXAMPLE
        Get-Greeting -Name 'World'

        Hello, World!
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Who to greet
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Name
    )

    process {
        foreach ($item in $Name) {
            Format-Greeting -Name $item
        }
    }
}
