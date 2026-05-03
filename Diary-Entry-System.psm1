Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Script:version = '1.0.0'

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
