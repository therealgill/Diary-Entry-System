function Set-DefaultDiary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DiaryName
    )

    Initialize-DiaryConfiguration

    $diaryPath = Get-DiaryFilePath -DiaryName $DiaryName
    if (-not (Test-Path -Path $diaryPath)) {
        '[]' | Set-Content -Path $diaryPath -Encoding UTF8
    }

    $Script:DiaryConfiguration.DefaultDiary = $DiaryName
    $Script:CurrentDiary = $DiaryName
    Save-DiaryConfiguration -Configuration $Script:DiaryConfiguration -ConfigurationPath (Get-DiaryConfigurationPath)
} # Set-DefaultDiary
