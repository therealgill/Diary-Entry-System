function Get-DiaryConfigurationPath {
    [CmdletBinding()]
    param()

    $existingConfigPathVariable = Get-Variable -Scope Script -Name DiaryConfigurationPath -ErrorAction SilentlyContinue
    if ($null -ne $existingConfigPathVariable -and -not [string]::IsNullOrWhiteSpace($existingConfigPathVariable.Value)) {
        return $existingConfigPathVariable.Value
    }

    if (-not [string]::IsNullOrWhiteSpace($env:DES_CONFIG_PATH)) {
        $Script:DiaryConfigurationPath = $env:DES_CONFIG_PATH
        return $Script:DiaryConfigurationPath
    }

    $candidateRoots = @()
    if (-not [string]::IsNullOrWhiteSpace($env:OneDrive)) {
        $candidateRoots += $env:OneDrive
    }

    $documentsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
    if (-not [string]::IsNullOrWhiteSpace($documentsPath)) {
        $candidateRoots += $documentsPath
    }

    $candidateRoots += (Get-UserDataDirectory)

    foreach ($root in ($candidateRoots | Select-Object -Unique)) {
        $candidate = Join-Path -Path $root -ChildPath 'Diary-Entry-System/DiaryConfig.json'
        if (Test-Path -Path $candidate) {
            $Script:DiaryConfigurationPath = $candidate
            return $Script:DiaryConfigurationPath
        }
    }

    $preferredRoot = if (-not [string]::IsNullOrWhiteSpace($env:OneDrive)) {
        $env:OneDrive
    } else {
        Get-UserDataDirectory
    }

    $Script:DiaryConfigurationPath = Join-Path -Path $preferredRoot -ChildPath 'Diary-Entry-System/DiaryConfig.json'
    return $Script:DiaryConfigurationPath
} # Get-DiaryConfigurationPath
