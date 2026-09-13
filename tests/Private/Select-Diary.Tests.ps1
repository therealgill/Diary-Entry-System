. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Select-Diary' {
    BeforeAll {
        function Initialize-DiaryConfiguration { }
        function Get-DiaryFiles { }
        function Get-DiaryFilePath { param([string]$DiaryName) throw 'stub-not-configured' }
        function Set-DefaultDiary { param([string]$DiaryName) }
        function Read-Confirmation { param([string]$Prompt, [string[]]$AcceptPattern) $false }
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/Select-Diary.ps1')
    }

    AfterEach {
        Remove-Variable -Scope Script -Name CurrentDiary -ErrorAction SilentlyContinue
    }

    It 'returns false when the user cancels with a blank name' {
        Mock Get-DiaryFiles { @() }
        Mock Read-Host { '' }

        Select-Diary | Should -BeFalse
    }

    It 'creates the diary file when it does not exist and sets it as current' {
        $tempFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString() + '.json')

        try {
            Mock Get-DiaryFiles { @() }
            Mock Get-DiaryFilePath { $tempFile }
            Mock Read-Host { 'NewDiary' }
            Mock Read-Confirmation { $false }
            Mock Set-DefaultDiary { }

            $result = Select-Diary

            $result | Should -BeTrue
            Test-Path -Path $tempFile | Should -BeTrue
            $Script:CurrentDiary | Should -Be 'NewDiary'
            Should -Invoke Set-DefaultDiary -Times 0
        } finally {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }

    It 'sets the diary as default without prompting when -SetAsDefault is used' {
        $tempFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString() + '.json')
        '[]' | Set-Content -Path $tempFile -Encoding UTF8

        try {
            Mock Get-DiaryFiles { @() }
            Mock Get-DiaryFilePath { $tempFile }
            Mock Read-Host { 'NewDiary' }
            Mock Set-DefaultDiary { }

            $result = Select-Diary -SetAsDefault

            $result | Should -BeTrue
            Should -Invoke Set-DefaultDiary -Times 1 -ParameterFilter { $DiaryName -eq 'NewDiary' }
            Should -Invoke Read-Host -Times 1
        } finally {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }

    It 'sets the diary as default when the user answers yes to the prompt' {
        $tempFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString() + '.json')
        '[]' | Set-Content -Path $tempFile -Encoding UTF8

        try {
            Mock Get-DiaryFiles { @() }
            Mock Get-DiaryFilePath { $tempFile }
            Mock Read-Host { 'NewDiary' }
            Mock Read-Confirmation { $true }
            Mock Set-DefaultDiary { }

            Select-Diary | Out-Null

            Should -Invoke Set-DefaultDiary -Times 1 -ParameterFilter { $DiaryName -eq 'NewDiary' }
        } finally {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}
