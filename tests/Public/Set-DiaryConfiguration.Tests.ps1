. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Set-DiaryConfiguration' {
    BeforeAll {
        Import-Module $global:ManifestPath -Force
    }

    It 'writes config and creates default diary non-interactively' {
        InModuleScope $global:ModuleName {
            $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
            $configDir = Join-Path -Path $tempRoot -ChildPath 'config'
            $diariesDir = Join-Path -Path $tempRoot -ChildPath 'diaries'
            $configPath = Join-Path -Path $configDir -ChildPath 'DiaryConfig.json'

            try {
                $result = Set-DiaryConfiguration -ConfigDirectory $configDir -DiariesDirectory $diariesDir -ConfigurationPath $configPath -DefaultDiary 'Personal'

                $result.DefaultDiary | Should -Be 'Personal'
                Test-Path -Path $configPath | Should -BeTrue
                Test-Path -Path (Join-Path -Path $diariesDir -ChildPath 'Personal.json') | Should -BeTrue
            } finally {
                Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
