. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Get-DiaryFilePath' {
    BeforeAll {
        function Initialize-DiaryConfiguration { }
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/Get-DiaryFilePath.ps1')
    }

    BeforeEach {
        $Script:DiaryConfiguration = [pscustomobject]@{ DiariesDirectory = '/diaries' }
    }

    AfterEach {
        Remove-Variable -Scope Script -Name DiaryConfiguration -ErrorAction SilentlyContinue
    }

    It 'builds a path by joining the diaries directory with the diary name' {
        Get-DiaryFilePath -DiaryName 'Personal' | Should -Be (Join-Path -Path '/diaries' -ChildPath 'Personal.json')
    }

    It 'replaces invalid file name characters with underscores' {
        $invalidChar = [IO.Path]::GetInvalidFileNameChars()[0]
        $diaryName = "My{0}Diary" -f $invalidChar

        $result = Get-DiaryFilePath -DiaryName $diaryName

        $result | Should -Be (Join-Path -Path '/diaries' -ChildPath 'My_Diary.json')
    }

    It 'throws when DiaryName is empty' {
        { Get-DiaryFilePath -DiaryName '' } | Should -Throw
    }
}
