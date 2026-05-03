<#
.SYNOPSIS
Launches the interactive diary application menu.

.DESCRIPTION
Starts the diary command loop, displays the menu, and processes user choices
until the user exits. The command attempts to set a friendly window title when
the host supports it and restores the original title on exit.

.EXAMPLE
Invoke-Diary

Starts the interactive diary session.

.OUTPUTS
None. This command runs an interactive host loop.

.NOTES
Use this as the primary entry command when running the module interactively.
#>
function Invoke-Diary {
    [CmdletBinding()]
    param()

    Initialize-DiaryConfiguration

    # Preserve the original title so we can restore host state on exit.
    $originalTitle = $null
    try {
        $originalTitle = $Host.UI.RawUI.WindowTitle
        $Host.UI.RawUI.WindowTitle = ("Diary Entry System - {0}" -f $Script:CurrentDiary)
    } catch {
        # Some hosts do not support window title changes.
    }

    try {
        $notExit = $true
        do {
            # Redraw the screen before each menu cycle for a clean UI.
            Clear-Host
            $notExit = New-DiaryMenu
        } while ($notExit)
    } finally {
        # Restore host state even when runtime errors occur in the menu loop.
        Clear-Host
        if ($null -ne $originalTitle) {
            try {
                $Host.UI.RawUI.WindowTitle = $originalTitle
            } catch {
                # Ignore title restoration issues in unsupported hosts.
            }
        }
    }
} # Invoke-Diary