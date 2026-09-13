. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Initialize-DiaryConfiguration' {
    BeforeAll {
        function Get-DiaryConfigurationPath { throw 'stub-not-configured' }
        function Get-UserDataDirectory { throw 'stub-not-configured' }
        function Save-DiaryConfiguration { param($Configuration, $ConfigurationPath) }
        function Select-Diary { param([switch]$SetAsDefault) }
        function Get-DiaryFilePath {
            param([string]$DiaryName)
            Join-Path -Path $Script:DiaryConfiguration.DiariesDirectory -ChildPath ($DiaryName + '.json')
        }
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/Initialize-DiaryConfiguration.ps1')
    }

    BeforeEach {
        $script:originalOneDrive = $env:OneDrive
        $env:OneDrive = $null
        Remove-Variable -Scope Script -Name DiaryConfiguration -ErrorAction SilentlyContinue
        Remove-Variable -Scope Script -Name DiaryConfigurationPath -ErrorAction SilentlyContinue
        Remove-Variable -Scope Script -Name CurrentDiary -ErrorAction SilentlyContinue
    }

    AfterEach {
        $env:OneDrive = $script:originalOneDrive
        Remove-Variable -Scope Script -Name DiaryConfiguration -ErrorAction SilentlyContinue
        Remove-Variable -Scope Script -Name DiaryConfigurationPath -ErrorAction SilentlyContinue
        Remove-Variable -Scope Script -Name CurrentDiary -ErrorAction SilentlyContinue
    }

    It 'returns immediately when configuration is already cached' {
        $Script:DiaryConfiguration = [pscustomobject]@{ DiariesDirectory = '/already/loaded' }
        Mock Get-DiaryConfigurationPath { throw 'should not be called' }

        Initialize-DiaryConfiguration

        Should -Invoke Get-DiaryConfigurationPath -Times 0
    }

    It 'loads an existing valid configuration file' {
        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $configPath = Join-Path -Path $tempRoot -ChildPath 'DiaryConfig.json'
        $diariesDirectory = Join-Path -Path $tempRoot -ChildPath 'Diaries'
        New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null
        New-Item -Path $diariesDirectory -ItemType Directory -Force | Out-Null

        [pscustomobject]@{
            ConfigVersion    = 1
            ConfigDirectory  = $tempRoot
            DiariesDirectory = $diariesDirectory
            DefaultDiary     = 'Personal'
        } | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8

        try {
            Mock Get-DiaryConfigurationPath { $configPath }

            Initialize-DiaryConfiguration

            $Script:DiaryConfiguration.DefaultDiary | Should -Be 'Personal'
            $Script:CurrentDiary | Should -Be 'Personal'
            Test-Path -Path (Join-Path -Path $diariesDirectory -ChildPath 'Personal.json') | Should -BeTrue
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'throws when the loaded configuration is missing DiariesDirectory' {
        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $configPath = Join-Path -Path $tempRoot -ChildPath 'DiaryConfig.json'
        New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null

        [pscustomobject]@{
            ConfigVersion   = 1
            ConfigDirectory = $tempRoot
            DefaultDiary    = 'Personal'
        } | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8

        try {
            Mock Get-DiaryConfigurationPath { $configPath }

            { Initialize-DiaryConfiguration } | Should -Throw 'Configuration is missing DiariesDirectory.'
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'runs the setup wizard and saves a new configuration when no config file exists' {
        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $configPath = Join-Path -Path $tempRoot -ChildPath 'Config/DiaryConfig.json'
        $userDataDirectory = Join-Path -Path $tempRoot -ChildPath 'UserData'

        try {
            Mock Get-DiaryConfigurationPath { $configPath }
            Mock Get-UserDataDirectory { $userDataDirectory }
            Mock Save-DiaryConfiguration {
                $Configuration | ConvertTo-Json | Set-Content -Path $ConfigurationPath -Encoding UTF8
            }
            Mock Read-Host {
                switch -Wildcard ($Prompt) {
                    'Selection*' { '1' }
                    'Configuration directory*' { '' }
                    'Diaries directory*' { '' }
                    'Default diary name*' { 'Wizard' }
                    default { '' }
                }
            }

            Initialize-DiaryConfiguration

            $Script:DiaryConfiguration.DefaultDiary | Should -Be 'Wizard'
            Should -Invoke Save-DiaryConfiguration -Times 1
            Test-Path -Path $Script:DiaryConfiguration.DiariesDirectory | Should -BeTrue
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'runs the setup wizard when the existing configuration file contains corrupt JSON' {
        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $configPath = Join-Path -Path $tempRoot -ChildPath 'DiaryConfig.json'
        $userDataDirectory = Join-Path -Path $tempRoot -ChildPath 'UserData'
        New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null
        'not valid json {{{' | Set-Content -Path $configPath -Encoding UTF8

        try {
            Mock Get-DiaryConfigurationPath { $configPath }
            Mock Get-UserDataDirectory { $userDataDirectory }
            Mock Save-DiaryConfiguration {
                $Configuration | ConvertTo-Json | Set-Content -Path $ConfigurationPath -Encoding UTF8
            }
            Mock Read-Host {
                switch -Wildcard ($Prompt) {
                    'Selection*' { '1' }
                    'Configuration directory*' { '' }
                    'Diaries directory*' { '' }
                    'Default diary name*' { 'Recovered' }
                    default { '' }
                }
            }

            Initialize-DiaryConfiguration

            $Script:DiaryConfiguration.DefaultDiary | Should -Be 'Recovered'
            Should -Invoke Save-DiaryConfiguration -Times 1
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'prompts to select a default diary when the loaded configuration has none set' {
        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $configPath = Join-Path -Path $tempRoot -ChildPath 'DiaryConfig.json'
        $diariesDirectory = Join-Path -Path $tempRoot -ChildPath 'Diaries'
        New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null
        New-Item -Path $diariesDirectory -ItemType Directory -Force | Out-Null

        [pscustomobject]@{
            ConfigVersion    = 1
            ConfigDirectory  = $tempRoot
            DiariesDirectory = $diariesDirectory
            DefaultDiary     = ''
        } | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8

        try {
            Mock Get-DiaryConfigurationPath { $configPath }
            Mock Select-Diary {
                $Script:DiaryConfiguration.DefaultDiary = 'PickedByWizard'
            }

            Initialize-DiaryConfiguration

            Should -Invoke Select-Diary -Times 1 -ParameterFilter { $SetAsDefault -eq $true }
            $Script:DiaryConfiguration.DefaultDiary | Should -Be 'PickedByWizard'
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'throws when no default diary can be established' {
        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $configPath = Join-Path -Path $tempRoot -ChildPath 'DiaryConfig.json'
        $diariesDirectory = Join-Path -Path $tempRoot -ChildPath 'Diaries'
        New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null
        New-Item -Path $diariesDirectory -ItemType Directory -Force | Out-Null

        [pscustomobject]@{
            ConfigVersion    = 1
            ConfigDirectory  = $tempRoot
            DiariesDirectory = $diariesDirectory
            DefaultDiary     = ''
        } | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8

        try {
            Mock Get-DiaryConfigurationPath { $configPath }
            Mock Select-Diary { }

            { Initialize-DiaryConfiguration } | Should -Throw 'A default diary is required to continue.'
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
