<#
.SYNOPSIS
Creates a diary and optionally sets it as current/default.

.DESCRIPTION
Creates a new diary JSON file in the configured diaries directory when it does
not exist, selects it as the current diary by default, and can optionally set it
as the default diary.

.PARAMETER Name
Name of the diary to create or select.

.PARAMETER SetAsDefault
Sets the diary as the default diary for future launches.

.PARAMETER DoNotSelect
Prevents switching the current diary to this diary.

.EXAMPLE
New-Diary -Name Work

Creates (if needed) and selects the Work diary.

.EXAMPLE
New-Diary -Name Personal -SetAsDefault

Creates (if needed), selects, and sets Personal as the default diary.

.OUTPUTS
pscustomobject.
#>
function New-Diary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [switch]$SetAsDefault,

        [switch]$DoNotSelect
    )

    Initialize-DiaryConfiguration

    $diaryPath = Get-DiaryFilePath -DiaryName $Name
    $created = $false
    if (-not (Test-Path -Path $diaryPath)) {
        '[]' | Set-Content -Path $diaryPath -Encoding UTF8
        $created = $true
    }

    if (-not $DoNotSelect) {
        $Script:CurrentDiary = $Name
    }

    if ($SetAsDefault) {
        Set-DefaultDiary -DiaryName $Name
    }

    [pscustomobject]@{
        Name          = $Name
        Path          = $diaryPath
        Created       = $created
        IsCurrent     = (-not $DoNotSelect)
        IsDefault     = [bool]$SetAsDefault
    }
} # New-Diary
