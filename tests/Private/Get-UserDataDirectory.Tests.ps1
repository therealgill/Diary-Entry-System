. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Get-UserDataDirectory' {
    BeforeAll {
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/Get-UserDataDirectory.ps1')
    }

    It 'returns a non-empty path' {
        $result = Get-UserDataDirectory

        $result | Should -Not -BeNullOrEmpty
    }

    It 'prefers the LocalApplicationData special folder when available' {
        $localAppData = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)

        if ([string]::IsNullOrWhiteSpace($localAppData)) {
            Set-ItResult -Skipped -Because 'LocalApplicationData is not defined on this platform'
        } else {
            Get-UserDataDirectory | Should -Be $localAppData
        }
    }
}
