<#
.SYNOPSIS
Lists diaries available in the configured diary store.

.DESCRIPTION
Returns diary names discovered in the configured diaries directory and includes
flags for whether each diary is the current diary and/or default diary.

.PARAMETER IncludePath
Includes full file paths in returned objects.

.EXAMPLE
Get-Diary

Returns available diaries with current/default flags.

.EXAMPLE
Get-Diary -IncludePath

Returns available diaries including file path information.

.OUTPUTS
pscustomobject.
#>
function Get-Diary {
    [CmdletBinding()]
    param(
        [switch]$IncludePath
    )

    Initialize-DiaryConfiguration

    $defaultDiary = $Script:DiaryConfiguration.DefaultDiary
    $currentDiaryVariable = Get-Variable -Scope Script -Name CurrentDiary -ErrorAction SilentlyContinue
    $currentDiary = if ($null -ne $currentDiaryVariable) { [string]$currentDiaryVariable.Value } else { [string]$defaultDiary }

    $diaries = foreach ($file in (Get-DiaryFiles)) {
        $obj = [ordered]@{
            Name      = $file.BaseName
            IsDefault = ($file.BaseName -eq $defaultDiary)
            IsCurrent = ($file.BaseName -eq $currentDiary)
        }

        if ($IncludePath) {
            $obj.Path = $file.FullName
        }

        [pscustomobject]$obj
    }

    $diaries
} # Get-Diary
