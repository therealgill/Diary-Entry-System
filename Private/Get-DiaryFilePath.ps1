function Get-DiaryFilePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DiaryName
    )

    Initialize-DiaryConfiguration

    $safeName = $DiaryName
    foreach ($invalid in [IO.Path]::GetInvalidFileNameChars()) {
        $safeName = $safeName.Replace([string]$invalid, '_')
    }

    Join-Path -Path $Script:DiaryConfiguration.DiariesDirectory -ChildPath ($safeName + '.json')
} # Get-DiaryFilePath
