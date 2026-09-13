. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'New-Diary' {
    BeforeAll {
        Import-Module $global:ManifestPath -Force
    }

    It 'creates a diary file and sets it as current by default' {
        InModuleScope $global:ModuleName {
            $tempDir = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
            New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

            try {
                Mock Initialize-DiaryConfiguration {}
                $Script:DiaryConfiguration = [pscustomobject]@{
                    DiariesDirectory = $tempDir
                    DefaultDiary = 'Personal'
                }

                $result = New-Diary -Name 'Work'

                $result.Name | Should -Be 'Work'
                $result.Created | Should -BeTrue
                $Script:CurrentDiary | Should -Be 'Work'
                Test-Path -Path (Join-Path -Path $tempDir -ChildPath 'Work.json') | Should -BeTrue
            } finally {
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    It 'calls Set-DefaultDiary when requested' {
        InModuleScope $global:ModuleName {
            $tempDir = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
            New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

            try {
                Mock Initialize-DiaryConfiguration {}
                Mock Set-DefaultDiary {}
                $Script:DiaryConfiguration = [pscustomobject]@{ DiariesDirectory = $tempDir; DefaultDiary = 'Personal' }

                $null = New-Diary -Name 'Personal2' -SetAsDefault

                Should -Invoke Set-DefaultDiary -Times 1 -Exactly -ParameterFilter { $DiaryName -eq 'Personal2' }
            } finally {
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
