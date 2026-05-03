<#
.SYNOPSIS
Displays recent diary entries.

.DESCRIPTION
Reads one or more diary JSON stores, filters entries created by this tool,
sorts them by entry timestamp in descending order, and prints the most recent
entries to the host. If no diary entries are present, a friendly message is
shown instead.

.PARAMETER NumberOfEntries
Number of most recent diary entries to display. Valid range is 1 through 1000.
Defaults to 3.

.PARAMETER AllDiaries
When specified, reads entries across all diary files in the configured diaries
directory. By default, only the currently selected diary is queried.

.EXAMPLE
Get-DiaryEntry

Displays the 3 most recent diary entries.

.EXAMPLE
Get-DiaryEntry -NumberOfEntries 10

Displays the 10 most recent diary entries.

.EXAMPLE
Get-DiaryEntry -NumberOfEntries 20 -AllDiaries

Displays the 20 most recent entries across all diaries.

.OUTPUTS
None. This command writes formatted output to the host.

.NOTES
This command is interactive and pauses for a key press before returning.
#>
function Get-DiaryEntry {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 1000)]
        [int]$NumberOfEntries = 3,

        [switch]$AllDiaries
    )

    # Refresh the console before rendering formatted entry output.
    Clear-Host
    Initialize-DiaryConfiguration

    $diaryFiles = if ($AllDiaries) {
        Get-DiaryFiles
    } else {
        @(Get-Item -Path (Get-JSONPath))
    }

    $allEntries = @()
    foreach ($file in $diaryFiles) {
        $jsonText = Get-Content -Path $file.FullName -Raw
        if ([string]::IsNullOrWhiteSpace($jsonText)) {
            continue
        }

        $entries = @($jsonText | ConvertFrom-Json)
        foreach ($entry in $entries) {
            if ($entry.Title -ne 'DIARY') {
                continue
            }

            $allEntries += [pscustomobject]@{
                Date        = [datetime]$entry.DateEntered
                SourceDiary = $file.BaseName
                ShortDesc   = $entry.ShortDesc
                Content     = $entry.Desc
            }
        }
    }

    $recentDiaryEntries = $allEntries |
        Sort-Object -Property Date -Descending |
        Select-Object -First $NumberOfEntries

    if (-not $recentDiaryEntries) {
        Write-Host 'No diary entries found.'
    } else {
        $recentDiaryEntries | Format-List -Property Date, SourceDiary, ShortDesc, Content | Out-Host
    }

    <#
        Host-specific hint for long output pages. This does not affect command
        behavior but improves discoverability for keyboard navigation.
    #>
    Write-Host 'Remember, [Ctrl+Shift+Up/Down] will scroll up/down when displaying too many entries'
    Wait-ForAnyKey
} # Get-DiaryEntry
