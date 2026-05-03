function Get-UserDataDirectory {
    [CmdletBinding()]
    param()

    $localAppData = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
    if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
        return $localAppData
    }

    $userProfile = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
    if (-not [string]::IsNullOrWhiteSpace($userProfile)) {
        return (Join-Path -Path $userProfile -ChildPath '.local/share')
    }

    throw 'Unable to resolve a user data directory.'
} # Get-UserDataDirectory
