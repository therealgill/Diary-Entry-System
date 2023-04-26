function New-ProgressItem {
    param (
        $DateOfProgress = ( Get-Date -Format "MM-dd-yyyy" ),
        [Parameter(Mandatory)] $Title,
        [Parameter(Mandatory)] $ShortDesc,
        $Desc,
        [float]$HoursWorked = 0,
        $JSONPath = (Get-JSONPath)
    )
    $progressEvents = @( Get-Content $JSONPath | ConvertFrom-JSON )
    $progressEvents += [PSCustomObject]@{
        Title          = $Title
        ShortDesc      = $ShortDesc
        Desc           = $Desc
        DateEntered    = (Get-Date)
        DateOfProgress = ( Get-Date -Date $DateOfProgress -Format "MM-dd-yyyy" )
        HoursWorked    = if ( $HoursWorked -ne 0 ) { $HoursWorked } else { $null }
    }
    $progressEvents | Convertto-JSON -Depth 10 | Set-Content $JSONPath
} # New-ProgressItem
function Get-JSONPath {
    if ( Test-Path ($env:OneDrive) ) {
        if ( Test-Path ($env:OneDrive + "\Progress.json") ) { ($env:OneDrive + "\Progress.json") }
        else {
            try { New-Item -Path ($env:OneDrive + "\Progress.json") }
            catch { <# COULDN'T MAKE FILE IN ONEDRIVE #> }
        }
    }
} # Get-JSONPath
function New-DiaryEntry {
    $entry = [pscustomobject]@{
        ShortDesc = Read-Host -Prompt "Short Description"
        Content   = Read-Host -Prompt "Content"
    }
    New-ProgressItem -Title ("DIARY") -ShortDesc ($entry.ShortDesc) -Desc ($entry.Content)
} # New-DiaryEntry
function Wait-ForAnyKey {
    Write-Host "Press any key to continue"
    [void][System.Console]::ReadKey($FALSE)
} # Wait-ForAnyKey
function Get-DiaryEntry {
    param($NumberOfEntries)
    Clear-Host
    ( (Get-Content (Get-JSONPath) | ConvertFrom-JSON ) |
        Where-Object { $_.Title -eq 'DIARY' } |
        Select-Object DateEntered, ShortDesc, Desc |
        Sort-Object { [System.DateTime]::Parse( $_.DateEntered ) } -Descending )[0..$(if ($NumberOfEntries -eq 0) { 2 } else { $NumberOfEntries - 1 })] |
        Format-List -Property * |
        Out-Host
    Write-Host "Remember, [Ctrl+Shift+Up/Down] will scroll up/down when displaying too many entries"
    Wait-ForAnyKey
} # Get-DiaryEntry
function New-DiaryMenu {
    $dVer = $Script:version
    Write-Host "
╔════════════════════════════╦══════════════════╗
║ Diary Entry System v$dVer  ║ Author: MG       ║
╠═══╦═══════════════╦════════╩══════════════════╣
║ # ║    Command    ║        Description        ║
╠═══╬═══════════════╬═══════════════════════════╣
║ 1 ║ New Entry     ║ Create a new diary entry  ║
║ 2 ║ Display Entry ║ Display # of past entries ║
║ 3 ║ Exit          ║ Exit diary entry system   ║
╚═══╩═══════════════╩═══════════════════════════╝"
    try {
        switch ( [int](Read-Host -Prompt "Command" ) ) {
            1 { New-DiaryEntry }
            2 { Get-DiaryEntry -NumberOfEntries ([int](Read-Host -Prompt "How many recent diary entries (3)")) }
            3 { return $false }
            default { [int]"Don't get cute..." }
        }
    } catch {
        Clear-Host
        Write-Host -ForegroundColor DarkRed "[ NOTE : `"Don't get cute...`" ]"
        New-DiaryMenu
    }
    return $true
} # New-DiaryMenu
function Invoke-Driver {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $Script:orgtitle = $Host.UI.RawUI.WindowTitle
        $Host.UI.RawUI.WindowTitle = "Diary Entry System"
        $notExit = $true
        do {
            Clear-Host
            $notExit = New-DiaryMenu
        } while ( $notExit )
    } finally {
        Clear-Host
        $Host.UI.RawUI.WindowTitle = $Script:orgtitle
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
    }
} # Invoke-Driver
$Script:version = '0.9.0'
Invoke-Driver
