. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Get-DiaryEntry' {
    BeforeAll {
        Import-Module $global:ManifestPath -Force
    }

    It 'shows no-entry message when no diary entries exist' {
        InModuleScope $global:ModuleName {
            $tempFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString() + '.json')
            '[]' | Set-Content -Path $tempFile -Encoding UTF8

            try {
                Mock Initialize-DiaryConfiguration {}
                Mock Get-JSONPath { return $tempFile }
                Mock Wait-ForAnyKey {}
                Mock Clear-Host {}
                Mock Write-Host {}
                Mock Out-Host {}

                Get-DiaryEntry -NumberOfEntries 3

                Should -Invoke Write-Host -Times 1 -ParameterFilter { $Object -eq 'No diary entries found.' }
                Should -Invoke Wait-ForAnyKey -Times 1
            } finally {
                Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
