function Wait-ForAnyKey {
    [CmdletBinding()]
    param()

    Write-Host 'Press any key to continue'
    try {
        if ([Console]::IsInputRedirected) {
            [void](Read-Host -Prompt 'Press Enter to continue')
            return
        }

        [void][System.Console]::ReadKey($false)
    } catch {
        [void](Read-Host -Prompt 'Press Enter to continue')
    }
} # Wait-ForAnyKey
