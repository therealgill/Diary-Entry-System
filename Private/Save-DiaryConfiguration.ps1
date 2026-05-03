function Save-DiaryConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Configuration,

        [Parameter(Mandatory)]
        [string]$ConfigurationPath
    )

    $configDirectory = Split-Path -Path $ConfigurationPath -Parent
    if (-not (Test-Path -Path $configDirectory)) {
        New-Item -Path $configDirectory -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path -Path $Configuration.DiariesDirectory)) {
        New-Item -Path $Configuration.DiariesDirectory -ItemType Directory -Force | Out-Null
    }

    $Configuration | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigurationPath -Encoding UTF8
} # Save-DiaryConfiguration
