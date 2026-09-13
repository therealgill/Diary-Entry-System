. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Set-DefaultDiary' {
    BeforeAll {
        function Initialize-DiaryConfiguration { }
        function Get-DiaryFilePath { param([string]$DiaryName) throw 'stub-not-configured' }
        function Get-DiaryConfigurationPath { throw 'stub-not-configured' }
        function Save-DiaryConfiguration { param($Configuration, $ConfigurationPath) }
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/Set-DefaultDiary.ps1')
    }

    AfterEach {
        Remove-Variable -Scope Script -Name DiaryConfiguration -ErrorAction SilentlyContinue
        Remove-Variable -Scope Script -Name CurrentDiary -ErrorAction SilentlyContinue
    }

    It 'updates the configuration, current diary, and persists the change' {
        $tempFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString() + '.json')
        '[]' | Set-Content -Path $tempFile -Encoding UTF8
        $Script:DiaryConfiguration = [pscustomobject]@{ DefaultDiary = 'Old' }

        try {
            Mock Get-DiaryFilePath { $tempFile }
            Mock Get-DiaryConfigurationPath { '/config/DiaryConfig.json' }
            Mock Save-DiaryConfiguration { }

            Set-DefaultDiary -DiaryName 'New'

            $Script:DiaryConfiguration.DefaultDiary | Should -Be 'New'
            $Script:CurrentDiary | Should -Be 'New'
            Should -Invoke Save-DiaryConfiguration -Times 1 -ParameterFilter {
                $Configuration.DefaultDiary -eq 'New' -and $ConfigurationPath -eq '/config/DiaryConfig.json'
            }
        } finally {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }

    It 'creates the diary file when it does not already exist' {
        $tempFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString() + '.json')
        $Script:DiaryConfiguration = [pscustomobject]@{ DefaultDiary = 'Old' }

        try {
            Mock Get-DiaryFilePath { $tempFile }
            Mock Get-DiaryConfigurationPath { '/config/DiaryConfig.json' }
            Mock Save-DiaryConfiguration { }

            Test-Path -Path $tempFile | Should -BeFalse

            Set-DefaultDiary -DiaryName 'New'

            Test-Path -Path $tempFile | Should -BeTrue
            (Get-Content -Path $tempFile -Raw).Trim() | Should -Be '[]'
        } finally {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}
