. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'New-DiaryMenu' {
    BeforeAll {
        Import-Module $global:ManifestPath -Force
        function Initialize-DiaryConfiguration {}
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/New-DiaryMenu.ps1')
        $Script:version = '1.0.0'
        $Script:CurrentDiary = 'TestDiary'
    }

    It 'returns false for Exit command' {
        Mock Read-Host {
            param([string]$Prompt)
            if ($Prompt -eq 'Command') {
                return '4'
            }

            return ''
        }

        $result = New-DiaryMenu
        $result | Should -BeFalse
    }

    It 'uses default entry count when command 2 count prompt is blank' {
        Mock Read-Host {
            param([string]$Prompt)
            if ($Prompt -eq 'Command') {
                return '2'
            }

            if ($Prompt -eq 'How many recent diary entries (3)') {
                return ''
            }

            if ($Prompt -eq 'Scope: Current diary or All diaries? (C/A)') {
                return 'C'
            }

            return ''
        }

        Mock Get-DiaryEntry {}

        $result = New-DiaryMenu

        $result | Should -BeTrue
        Assert-MockCalled Get-DiaryEntry -Times 1 -Exactly -ParameterFilter {
            $NumberOfEntries -eq 3
        }
    }
}
