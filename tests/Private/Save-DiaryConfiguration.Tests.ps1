. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Save-DiaryConfiguration' {
    BeforeAll {
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/Save-DiaryConfiguration.ps1')
    }

    It 'creates the config and diaries directories and writes the configuration as JSON' {
        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $configPath = Join-Path -Path $tempRoot -ChildPath 'Config/DiaryConfig.json'
        $diariesDirectory = Join-Path -Path $tempRoot -ChildPath 'Diaries'
        $configuration = [pscustomobject]@{
            ConfigVersion    = 1
            ConfigDirectory  = (Split-Path -Path $configPath -Parent)
            DiariesDirectory = $diariesDirectory
            DefaultDiary     = 'Personal'
        }

        try {
            Save-DiaryConfiguration -Configuration $configuration -ConfigurationPath $configPath

            Test-Path -Path (Split-Path -Path $configPath -Parent) | Should -BeTrue
            Test-Path -Path $diariesDirectory | Should -BeTrue
            Test-Path -Path $configPath | Should -BeTrue

            $saved = Get-Content -Path $configPath -Raw | ConvertFrom-Json
            $saved.DefaultDiary | Should -Be 'Personal'
            $saved.DiariesDirectory | Should -Be $diariesDirectory
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'overwrites an existing configuration file' {
        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $configPath = Join-Path -Path $tempRoot -ChildPath 'DiaryConfig.json'
        $diariesDirectory = Join-Path -Path $tempRoot -ChildPath 'Diaries'
        New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null
        New-Item -Path $diariesDirectory -ItemType Directory -Force | Out-Null
        '{"DefaultDiary":"Old"}' | Set-Content -Path $configPath -Encoding UTF8

        $configuration = [pscustomobject]@{
            ConfigVersion    = 1
            ConfigDirectory  = $tempRoot
            DiariesDirectory = $diariesDirectory
            DefaultDiary     = 'New'
        }

        try {
            Save-DiaryConfiguration -Configuration $configuration -ConfigurationPath $configPath

            $saved = Get-Content -Path $configPath -Raw | ConvertFrom-Json
            $saved.DefaultDiary | Should -Be 'New'
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
