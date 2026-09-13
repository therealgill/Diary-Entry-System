function Read-Confirmation {
    <#
    .SYNOPSIS
        Prompts the user and returns whether the response matches an accepted pattern.
    .DESCRIPTION
        Centralizes the y/n and choice-matching prompt logic shared by interactive menus
        (e.g. confirmation prompts, "all vs current" scope choices).
    .PARAMETER Prompt
        The text passed to Read-Host.
    .PARAMETER AcceptPattern
        One or more regex patterns; the response is accepted if any pattern matches.
        Defaults to a case-insensitive y/yes match.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Prompt,

        [ValidateNotNullOrEmpty()]
        [string[]]$AcceptPattern = @('^(?i)y(es)?$')
    )

    $response = Read-Host -Prompt $Prompt

    foreach ($pattern in $AcceptPattern) {
        if ($response -match $pattern) {
            return $true
        }
    }

    return $false
} # Read-Confirmation
