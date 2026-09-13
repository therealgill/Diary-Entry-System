function Select-Diary {
    [CmdletBinding()]
    param(
        [switch]$SetAsDefault
    )

    Initialize-DiaryConfiguration

    $diaryFiles = Get-DiaryFiles
    if ($diaryFiles.Count -gt 0) {
        Write-Host 'Available diaries:'
        $index = 1
        foreach ($file in $diaryFiles) {
            Write-Host ("  {0}. {1}" -f $index, $file.BaseName)
            $index++
        }
    } else {
        Write-Host 'No diaries found yet. Enter a name to create one.'
    }

    $inputName = Read-Host -Prompt 'Diary name to open/create (blank to cancel)'
    if ([string]::IsNullOrWhiteSpace($inputName)) {
        return $false
    }

    $diaryPath = Get-DiaryFilePath -DiaryName $inputName
    if (-not (Test-Path -Path $diaryPath)) {
        '[]' | Set-Content -Path $diaryPath -Encoding UTF8
    }

    $Script:CurrentDiary = $inputName

    if ($SetAsDefault) {
        Set-DefaultDiary -DiaryName $inputName
        return $true
    }

    if (Read-Confirmation -Prompt 'Set this diary as default? (y/N)') {
        Set-DefaultDiary -DiaryName $inputName
    }

    return $true
} # Select-Diary
