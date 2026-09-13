. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Interactive helper functions' {
    It 'Read-String reads input from redirected stdin' {
        $readStringPath = Join-Path -Path $global:RepoRoot -ChildPath 'Private/Read-String.ps1'
        $code = @"
. '$readStringPath'
`$result = Read-String -Prompt 'Content'
Write-Output `$result
"@

        $result = Invoke-ExternalPwsh -Code $code -StdIn "hello`n"

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Match 'hello'
    }

    It 'Wait-ForAnyKey completes with redirected stdin' {
        $waitForAnyKeyPath = Join-Path -Path $global:RepoRoot -ChildPath 'Private/Wait-ForAnyKey.ps1'
        $code = @"
. '$waitForAnyKeyPath'
Wait-ForAnyKey
Write-Output 'done'
"@

        $result = Invoke-ExternalPwsh -Code $code -StdIn "`n"

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Match 'done'
    }

    It 'Read-Confirmation returns true for default y/yes pattern' {
        $readConfirmationPath = Join-Path -Path $global:RepoRoot -ChildPath 'Private/Read-Confirmation.ps1'
        $code = @"
. '$readConfirmationPath'
`$result = Read-Confirmation -Prompt 'Confirm'
Write-Output `$result
"@

        $result = Invoke-ExternalPwsh -Code $code -StdIn "yes`n"

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Match 'True'
    }

    It 'Read-Confirmation returns false when response does not match' {
        $readConfirmationPath = Join-Path -Path $global:RepoRoot -ChildPath 'Private/Read-Confirmation.ps1'
        $code = @"
. '$readConfirmationPath'
`$result = Read-Confirmation -Prompt 'Confirm'
Write-Output `$result
"@

        $result = Invoke-ExternalPwsh -Code $code -StdIn "n`n"

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Match 'False'
    }

    It 'Read-Confirmation matches a custom AcceptPattern' {
        $readConfirmationPath = Join-Path -Path $global:RepoRoot -ChildPath 'Private/Read-Confirmation.ps1'
        $code = @"
. '$readConfirmationPath'
`$result = Read-Confirmation -Prompt 'Scope' -AcceptPattern '^(?i)a(ll)?`$'
Write-Output `$result
"@

        $result = Invoke-ExternalPwsh -Code $code -StdIn "all`n"

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Match 'True'
    }
}
