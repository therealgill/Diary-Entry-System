function New-DiaryMenu {
    [CmdletBinding()]
    param()

    Initialize-DiaryConfiguration

    $dVer = $Script:version
    $currentDiaryVariable = Get-Variable -Scope Script -Name CurrentDiary -ErrorAction SilentlyContinue
    $currentDiaryLabel = if ($null -eq $currentDiaryVariable -or [string]::IsNullOrWhiteSpace([string]$currentDiaryVariable.Value)) {
        '<none>'
    } else {
        [string]$currentDiaryVariable.Value
    }
    Write-Host @"
╔══════════════════════════════════════════════════╗
║ Diary Entry System v$dVer                        ║
║ Current Diary: $currentDiaryLabel
╠═══╦════════════════════╦═════════════════════════╣
║ # ║      Command       ║       Description       ║
╠═══╬════════════════════╬═════════════════════════╣
║ 1 ║ New Entry          ║ Create a new diary entry║
║ 2 ║ Display Entries    ║ Show recent entries     ║
║ 3 ║ Switch Diary       ║ Open/create another     ║
║ 4 ║ Exit               ║ Exit diary system       ║
╚═══╩════════════════════╩═════════════════════════╝
"@

    $commandText = Read-Host -Prompt 'Command'
    $command = 0
    if (-not [int]::TryParse($commandText, [ref]$command)) {
        Write-Host -ForegroundColor DarkRed '[ NOTE : "Please enter 1, 2, 3, or 4." ]'
        return $true
    }

    switch ($command) {
        1 {
            New-DiaryEntry
            return $true
        }
        2 {
            $countText = Read-Host -Prompt 'How many recent diary entries (3)'
            $count = 3

            if (-not [string]::IsNullOrWhiteSpace($countText)) {
                if (-not [int]::TryParse($countText, [ref]$count) -or $count -lt 1) {
                    Write-Host -ForegroundColor DarkRed '[ NOTE : "Please enter a positive whole number." ]'
                    return $true
                }
            }

            $scopeText = Read-Host -Prompt 'Scope: Current diary or All diaries? (C/A)'
            if ($scopeText -match '^(?i)a(ll)?$') {
                Get-DiaryEntry -NumberOfEntries $count -AllDiaries
            } else {
                Get-DiaryEntry -NumberOfEntries $count
            }

            return $true
        }
        3 {
            [void](Select-Diary)
            return $true
        }
        4 {
            return $false
        }
        default {
            Write-Host -ForegroundColor DarkRed '[ NOTE : "Please enter 1, 2, 3, or 4." ]'
            return $true
        }
    }
} # New-DiaryMenu
