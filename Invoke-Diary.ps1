Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Manifest (.psd1) ModuleVersion is the single source of truth for the version string.
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Diary-Entry-System.psd1') -Force

Invoke-Diary
