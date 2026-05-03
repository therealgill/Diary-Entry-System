. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Get-JSONPath' {
    BeforeAll {
        function Initialize-DiaryConfiguration {}
        function Get-DiaryFilePath { param([string]$DiaryName) throw 'stub-not-configured' }
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/Get-JSONPath.ps1')
    }

    It 'creates and initializes the current diary json file when missing' {
        $tempFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString() + '.json')

        try {
            $Script:DiaryConfiguration = [pscustomobject]@{ DefaultDiary = 'TestDiary' }
            Mock Get-DiaryFilePath { return $tempFile }

            $jsonPath = Get-JSONPath

            $jsonPath | Should -Be $tempFile
            Test-Path -Path $jsonPath | Should -BeTrue

            $content = Get-Content -Path $jsonPath -Raw | ConvertFrom-Json
            @($content).Count | Should -Be 0
        } finally {
            Remove-Variable -Scope Script -Name DiaryConfiguration -ErrorAction SilentlyContinue
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}
