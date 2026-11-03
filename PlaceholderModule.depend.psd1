@{
    PSDependOptions  = @{
        AddToPath = $True
        Target    = 'build/modules'
        Tags      = 'Build'
    }

    ModuleBuilder    = 'latest'
    InvokeBuild      = 'latest'
    Pester           = '6.2.0'
    PSScriptAnalyzer = 'latest'
}
