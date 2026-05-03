function Get-JSONPath {
    [CmdletBinding()]
    param()

    Initialize-DiaryConfiguration

    $currentDiaryVariable = Get-Variable -Scope Script -Name CurrentDiary -ErrorAction SilentlyContinue
    $configuredDiary = $Script:DiaryConfiguration.DefaultDiary
    $currentDiary = if ($null -ne $currentDiaryVariable -and -not [string]::IsNullOrWhiteSpace([string]$currentDiaryVariable.Value)) {
        [string]$currentDiaryVariable.Value
    } else {
        [string]$configuredDiary
    }

    if ([string]::IsNullOrWhiteSpace($currentDiary)) {
        throw 'No current diary is set.'
    }

    $path = Get-DiaryFilePath -DiaryName $currentDiary
    if (-not (Test-Path -Path $path)) {
        '[]' | Set-Content -Path $path -Encoding UTF8
    }

    $jsonText = Get-Content -Path $path -Raw
    if ([string]::IsNullOrWhiteSpace($jsonText)) {
        '[]' | Set-Content -Path $path -Encoding UTF8
    } else {
        $null = $jsonText | ConvertFrom-Json
    }

    return $path
} # Get-JSONPath
