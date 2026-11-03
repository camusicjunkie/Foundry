@{
    RootModule        = 'PlaceholderModule.psm1'

    # Replaced at build time with the version GitVersion derives
    ModuleVersion     = '0.0.0'

    GUID              = '47969fb1-72d5-476a-953a-d976085f0904'
    Author            = 'John Steele'
    CompanyName       = 'Unknown'
    Copyright         = '(c) 2026 John Steele. All rights reserved.'
    Description       = 'ModuleDescription'
    PowerShellVersion = '5.1'

    # Always empty in source; Build-Module fills these in from source/Public
    FunctionsToExport = @()
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData       = @{
        PSData = @{
            Tags         = 'PowerShell'
            LicenseUri   = 'https://github.com/camusicjunkie/PlaceholderModule/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/camusicjunkie/PlaceholderModule'
            ReleaseNotes = 'https://github.com/camusicjunkie/PlaceholderModule/releases'
        }
    }
}
