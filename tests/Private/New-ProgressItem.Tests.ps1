. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'New-ProgressItem' {
    BeforeAll {
        . (Join-Path -Path $global:RepoRoot -ChildPath 'Private/New-ProgressItem.ps1')
    }

    It 'adds a new event to the JSON store' {
        $tempFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString() + '.json')
        '[]' | Set-Content -Path $tempFile -Encoding UTF8

        try {
            New-ProgressItem -Title 'DIARY' -ShortDesc 'Short text' -Desc 'Long text' -JSONPath $tempFile

            $events = @(Get-Content -Path $tempFile -Raw | ConvertFrom-Json)
            $events.Count | Should -Be 1
            $events[0].Title | Should -Be 'DIARY'
            $events[0].ShortDesc | Should -Be 'Short text'
            $events[0].Desc | Should -Be 'Long text'
            $events[0].HoursWorked | Should -BeNullOrEmpty
        } finally {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }

    It 'persists HoursWorked when non-zero' {
        $tempFile = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString() + '.json')
        '[]' | Set-Content -Path $tempFile -Encoding UTF8

        try {
            New-ProgressItem -Title 'DIARY' -ShortDesc 'Short text' -Desc 'Long text' -HoursWorked 1.5 -JSONPath $tempFile

            $events = @(Get-Content -Path $tempFile -Raw | ConvertFrom-Json)
            [double]$events[0].HoursWorked | Should -Be 1.5
        } finally {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}
