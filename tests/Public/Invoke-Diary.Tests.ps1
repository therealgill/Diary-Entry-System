. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Invoke-Diary' {
    BeforeAll {
        Import-Module $global:ManifestPath -Force
    }

    It 'loops until New-DiaryMenu returns false' {
        InModuleScope $global:ModuleName {
            $script:menuCalls = 0

            Mock Initialize-DiaryConfiguration {}
            Mock New-DiaryMenu {
                $script:menuCalls++
                if ($script:menuCalls -eq 1) {
                    return $true
                }

                return $false
            }

            Mock Clear-Host {}

            Invoke-Diary

            Assert-MockCalled New-DiaryMenu -Times 2 -Exactly
        }
    }
}
