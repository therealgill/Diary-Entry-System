[CmdletBinding()]
param(
    [switch]$InstallPester
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$pesterModule = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
if (-not $pesterModule -and $InstallPester) {
    Install-Module -Name Pester -Scope CurrentUser -Force -SkipPublisherCheck
    $pesterModule = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
}

if (-not $pesterModule) {
    throw 'Pester is not installed. Run: pwsh -File ./tests/Invoke-Tests.ps1 -InstallPester'
}

Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop

Invoke-Pester -Path $PSScriptRoot -Output Detailed
