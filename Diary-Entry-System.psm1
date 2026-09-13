Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Manifest (.psd1) ModuleVersion is the single source of truth for the version string.
$Script:version = if ($ExecutionContext.SessionState.Module) {
    $ExecutionContext.SessionState.Module.Version.ToString()
} else {
    (Import-PowerShellDataFile -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Diary-Entry-System.psd1')).ModuleVersion
}

$privatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$publicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'

foreach ($path in @($privatePath, $publicPath)) {
    if (-not (Test-Path -Path $path)) {
        throw "Required function path not found: $path"
    }

    Get-ChildItem -Path $path -Filter '*.ps1' -File |
        Sort-Object -Property Name |
        ForEach-Object {
            . $_.FullName
        }
}

Export-ModuleMember -Function @(
    'Get-Diary',
    'Invoke-Diary',
    'New-Diary',
    'New-DiaryEntry',
    'Get-DiaryEntry',
    'Set-DiaryConfiguration'
)
