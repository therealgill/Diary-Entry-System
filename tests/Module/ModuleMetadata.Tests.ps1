. (Join-Path -Path $PSScriptRoot -ChildPath '../Common/TestCommon.ps1')

Describe 'Diary-Entry-System module metadata and exports' {
    It 'has a valid module manifest' {
        $manifest = Test-ModuleManifest -Path $global:ManifestPath

        $manifest.Name | Should -Be 'Diary-Entry-System'
        $manifest.Version.ToString() | Should -Be '1.0.0'
        $manifest.PowerShellVersion.ToString() | Should -Be '7.0'
        $manifest.ExportedFunctions.Keys | Sort-Object | Should -Be @(
            'Get-Diary',
            'Get-DiaryEntry',
            'Invoke-Diary',
            'New-Diary',
            'New-DiaryEntry'
            'Set-DiaryConfiguration'
        )
    }

    It 'exports only the expected public functions' {
        Import-Module $global:ManifestPath -Force

        $exported = Get-Command -Module $global:ModuleName | Select-Object -ExpandProperty Name | Sort-Object
        $exported | Should -Be @(
            'Get-Diary',
            'Get-DiaryEntry',
            'Invoke-Diary',
            'New-Diary',
            'New-DiaryEntry'
            'Set-DiaryConfiguration'
        )
    }
}
