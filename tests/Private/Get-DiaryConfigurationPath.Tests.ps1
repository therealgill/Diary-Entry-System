. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Get-DiaryConfigurationPath' {
    BeforeAll {
        function Get-UserDataDirectory { }
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/Get-DiaryConfigurationPath.ps1')
    }

    BeforeEach {
        $script:originalOneDrive = $env:OneDrive
        $script:originalDesConfigPath = $env:DES_CONFIG_PATH
        $env:OneDrive = $null
        $env:DES_CONFIG_PATH = $null
        Remove-Variable -Scope Script -Name DiaryConfigurationPath -ErrorAction SilentlyContinue
    }

    AfterEach {
        $env:OneDrive = $script:originalOneDrive
        $env:DES_CONFIG_PATH = $script:originalDesConfigPath
        Remove-Variable -Scope Script -Name DiaryConfigurationPath -ErrorAction SilentlyContinue
    }

    It 'returns the cached script-scoped path without recomputation' {
        $Script:DiaryConfigurationPath = '/cached/DiaryConfig.json'
        Mock Get-UserDataDirectory { throw 'should not be called' }

        Get-DiaryConfigurationPath | Should -Be '/cached/DiaryConfig.json'
        Should -Invoke Get-UserDataDirectory -Times 0
    }

    It 'uses DES_CONFIG_PATH environment variable when set' {
        $env:DES_CONFIG_PATH = '/env/DiaryConfig.json'

        $result = Get-DiaryConfigurationPath

        $result | Should -Be '/env/DiaryConfig.json'
        $Script:DiaryConfigurationPath | Should -Be '/env/DiaryConfig.json'
    }

    It 'returns an existing candidate path when one is found' {
        # Use OneDrive (checked first) so a real config file in the test
        # machine's Documents folder cannot shadow the expected candidate.
        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        $expectedCandidate = Join-Path -Path $tempRoot -ChildPath 'Diary-Entry-System/DiaryConfig.json'
        New-Item -Path (Split-Path -Path $expectedCandidate -Parent) -ItemType Directory -Force | Out-Null
        '{}' | Set-Content -Path $expectedCandidate -Encoding UTF8

        try {
            $env:OneDrive = $tempRoot
            # Get-UserDataDirectory is always invoked to build the candidate list,
            # even though the OneDrive match below is found first in the loop.
            Mock Get-UserDataDirectory { $tempRoot }

            Get-DiaryConfigurationPath | Should -Be $expectedCandidate
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'falls back to a new path under the user data directory when no candidate exists' {
        # Documents is checked before the user data directory fallback, so a
        # pre-existing real config there would shadow the result. Move it aside
        # for the duration of this test and restore it afterward regardless of
        # outcome.
        $documentsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
        $realDocumentsCandidate = if (-not [string]::IsNullOrWhiteSpace($documentsPath)) {
            Join-Path -Path $documentsPath -ChildPath 'Diary-Entry-System'
        } else {
            $null
        }
        $backupPath = $null
        if ($realDocumentsCandidate -and (Test-Path -Path $realDocumentsCandidate)) {
            $backupPath = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
            Move-Item -Path $realDocumentsCandidate -Destination $backupPath
        }

        $tempRoot = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
        New-Item -Path $tempRoot -ItemType Directory -Force | Out-Null
        $env:OneDrive = $tempRoot
        Mock Get-UserDataDirectory { $tempRoot }

        try {
            $expected = Join-Path -Path $tempRoot -ChildPath 'Diary-Entry-System/DiaryConfig.json'

            Get-DiaryConfigurationPath | Should -Be $expected
            Test-Path -Path $expected | Should -BeFalse
        } finally {
            Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
            if ($backupPath) {
                Move-Item -Path $backupPath -Destination $realDocumentsCandidate -Force
            }
        }
    }
}
