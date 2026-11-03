Describe 'Get-Greeting: Unit' -Tag Unit {
    It 'Greets <Name>' -TestCases @(
        @{ Name = 'World'; Expected = 'Hello, World!' }
        @{ Name = 'John'; Expected = 'Hello, John!' }
    ) {
        Get-Greeting -Name $Name | Should -Be $Expected
    }

    It 'Greets each name from the pipeline' {
        'Ann', 'Bob' | Get-Greeting | Should -Be 'Hello, Ann!', 'Hello, Bob!'
    }

    It 'Rejects an empty name' {
        { Get-Greeting -Name '' } | Should -Throw
    }

    It 'Is exported and its helper is not' {
        (Get-Command -Module PlaceholderModule).Name | Should -Be 'Get-Greeting'
    }
}
