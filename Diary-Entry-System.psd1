@{
    RootModule = 'Diary-Entry-System.psm1'
    ModuleVersion = '1.0.0'
    GUID = '6d5f95df-590d-4c25-8e6d-7ebf8a655ef4'
    Author = 'MG'
    CompanyName = 'Unknown'
    Copyright = '(c) MG. All rights reserved.'
    Description = 'A simple, quaint diary/journal system.'
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core', 'Desktop')
    FunctionsToExport = @(
        'Get-Diary',
        'Invoke-Diary',
        'New-Diary',
        'New-DiaryEntry',
        'Get-DiaryEntry',
        'Set-DiaryConfiguration'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Diary', 'Journal', 'CLI')
        }
    }
}
