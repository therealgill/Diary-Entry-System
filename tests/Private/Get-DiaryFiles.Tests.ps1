. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Get-DiaryFiles' {
    BeforeAll {
        function Initialize-DiaryConfiguration { }
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/Get-DiaryFiles.ps1')
    }

    AfterEach {
        Remove-Variable -Scope Script -Name DiaryConfiguration -ErrorAction SilentlyContinue
    }

    It 'creates the diaries directory when it does not exist' {
        $tempDir = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $Script:DiaryConfiguration = [pscustomobject]@{ DiariesDirectory = $tempDir }

        try {
            Test-Path -Path $tempDir | Should -BeFalse

            $result = @(Get-DiaryFiles)

            Test-Path -Path $tempDir | Should -BeTrue
            $result.Count | Should -Be 0
        } finally {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'returns only json files sorted by name' {
        $tempDir = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
        $Script:DiaryConfiguration = [pscustomobject]@{ DiariesDirectory = $tempDir }

        try {
            '[]' | Set-Content -Path (Join-Path -Path $tempDir -ChildPath 'Zebra.json') -Encoding UTF8
            '[]' | Set-Content -Path (Join-Path -Path $tempDir -ChildPath 'Alpha.json') -Encoding UTF8
            'not json' | Set-Content -Path (Join-Path -Path $tempDir -ChildPath 'Notes.txt') -Encoding UTF8

            $result = @(Get-DiaryFiles)

            $result.Count | Should -Be 2
            $result[0].BaseName | Should -Be 'Alpha'
            $result[1].BaseName | Should -Be 'Zebra'
        } finally {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
