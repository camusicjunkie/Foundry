Describe 'Format-Greeting: Unit' -Tag Unit {
    BeforeAll {
        $module = @{ ModuleName = 'PlaceholderModule' }
    }

    It 'Trims the name before formatting it' {
        InModuleScope @module {
            Format-Greeting -Name '  World '
        } | Should -Be 'Hello, World!'
    }
}
