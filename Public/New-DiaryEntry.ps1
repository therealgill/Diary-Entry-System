<#
.SYNOPSIS
Creates a new diary entry.

.DESCRIPTION
Prompts the user for a short description and detailed content, then persists the
entry as a DIARY progress event in the currently selected diary JSON store.

.EXAMPLE
New-DiaryEntry

Prompts for entry details and saves a new diary record.

.OUTPUTS
None. The command records the entry and writes prompt text to the host.

.NOTES
This command is intentionally interactive and designed for console usage.
#>
function New-DiaryEntry {
    [CmdletBinding()]
    param()

    Initialize-DiaryConfiguration
    Write-Host ("Current diary: {0}" -f $Script:CurrentDiary)

    # Gather input in two forms: quick summary and free-form body text.
    $entry = [pscustomobject]@{
        ShortDesc = Read-Host -Prompt 'Short Description'
        Content   = Read-String -Prompt 'Content'
    }

    <#
        Persist the entry through the shared progress-item pipeline so diary
        records remain consistent with the existing data model.
    #>
    New-ProgressItem -Title 'DIARY' -ShortDesc $entry.ShortDesc -Desc $entry.Content
} # New-DiaryEntry
