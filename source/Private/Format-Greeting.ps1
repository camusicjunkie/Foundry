function Format-Greeting {
    <#
    .SYNOPSIS
        Formats a greeting with the module's greeting format.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Who the greeting is for
        [Parameter(Mandatory)]
        [string] $Name
    )

    $script:GreetingFormat -f ($Name -replace '^\s+|\s+$')
}
