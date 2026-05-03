function Get-DiaryFiles {
    [CmdletBinding()]
    param()

    Initialize-DiaryConfiguration

    if (-not (Test-Path -Path $Script:DiaryConfiguration.DiariesDirectory)) {
        New-Item -Path $Script:DiaryConfiguration.DiariesDirectory -ItemType Directory -Force | Out-Null
    }

    @(Get-ChildItem -Path $Script:DiaryConfiguration.DiariesDirectory -Filter '*.json' -File | Sort-Object -Property Name)
} # Get-DiaryFiles
