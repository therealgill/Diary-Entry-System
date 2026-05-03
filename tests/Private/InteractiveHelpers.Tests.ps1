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
}
