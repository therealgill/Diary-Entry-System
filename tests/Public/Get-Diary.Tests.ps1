. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Get-Diary' {
    BeforeAll {
        Import-Module $global:ManifestPath -Force
    }

    It 'returns diary list with current and default flags' {
        InModuleScope $global:ModuleName {
            Mock Initialize-DiaryConfiguration {}
            Mock Get-DiaryFiles {
                @(
                    [pscustomobject]@{ BaseName = 'Personal'; FullName = '/tmp/Personal.json' },
                    [pscustomobject]@{ BaseName = 'Work'; FullName = '/tmp/Work.json' }
                )
            }

            $Script:DiaryConfiguration = [pscustomobject]@{ DefaultDiary = 'Personal' }
            $Script:CurrentDiary = 'Work'

            $result = @(Get-Diary)

            $result.Count | Should -Be 2
            ($result | Where-Object Name -eq 'Personal').IsDefault | Should -BeTrue
            ($result | Where-Object Name -eq 'Work').IsCurrent | Should -BeTrue
        }
    }
}
