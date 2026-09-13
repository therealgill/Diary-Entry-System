. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Invoke-Diary.ps1 (root launcher)' {
    BeforeAll {
        $global:LauncherPath = Join-Path -Path $global:RepoRoot -ChildPath 'Invoke-Diary.ps1'
        Import-Module $global:ManifestPath -Force
    }

    It 'imports the module and exposes the expected public commands' {
        $commands = Get-Command -Module $global:ModuleName | Select-Object -ExpandProperty Name

        $commands | Should -Contain 'Get-Diary'
        $commands | Should -Contain 'Invoke-Diary'
        $commands | Should -Contain 'New-Diary'
        $commands | Should -Contain 'New-DiaryEntry'
        $commands | Should -Contain 'Get-DiaryEntry'
        $commands | Should -Contain 'Set-DiaryConfiguration'
    }

    It 'delegates to Import-Module + Invoke-Diary instead of re-implementing the dot-source bootstrap' {
        # Avoids actually invoking the interactive TUI loop; verifies the
        # launcher's mechanism via static content rather than execution.
        $content = Get-Content -Path $global:LauncherPath -Raw

        $content | Should -Match 'Import-Module\s+.*Diary-Entry-System\.psd1'
        $content | Should -Match '(?m)^Invoke-Diary\s*$'
        $content | Should -Not -Match 'Get-ChildItem'
    }

    It 'imports without throwing via the same mechanism the launcher uses' {
        { Import-Module -Name $global:ManifestPath -Force } | Should -Not -Throw
        Get-Command -Name 'Invoke-Diary' -Module $global:ModuleName -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }
}