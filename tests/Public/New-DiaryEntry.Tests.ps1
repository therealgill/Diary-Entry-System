. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'New-DiaryEntry' {
    BeforeAll {
        Import-Module $global:ManifestPath -Force
    }

    It 'collects prompts and saves as DIARY entry' {
        InModuleScope $global:ModuleName {
            Mock Initialize-DiaryConfiguration {}
            $Script:CurrentDiary = 'TestDiary'
            Mock Read-Host {
                param([string]$Prompt)
                if ($Prompt -eq 'Short Description') {
                    return 'A short description'
                }

                return ''
            }

            Mock Read-String { return 'Detailed entry content' }
            Mock New-ProgressItem {}

            New-DiaryEntry

            Should -Invoke New-ProgressItem -Times 1 -Exactly -ParameterFilter {
                $Title -eq 'DIARY' -and
                $ShortDesc -eq 'A short description' -and
                $Desc -eq 'Detailed entry content'
            }
        }
    }
}
