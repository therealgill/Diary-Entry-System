<#
.SYNOPSIS
Configures Diary Entry System storage paths non-interactively.

.DESCRIPTION
Creates or updates the Diary Entry System configuration file, ensures the
configured diaries directory exists, and ensures the configured default diary
file exists.

.PARAMETER StorageLocation
Base location used when ConfigDirectory is not explicitly provided.
Valid values: OneDrive, Documents, UserDataDirectory.

.PARAMETER ConfigDirectory
Directory where DiaryConfig.json will be written.

.PARAMETER DiariesDirectory
Directory where diary JSON files are stored.

.PARAMETER DefaultDiary
Default diary name opened when Invoke-Diary starts.

.PARAMETER ConfigurationPath
Explicit full path to DiaryConfig.json. If omitted, this is derived from
ConfigDirectory.

.EXAMPLE
Set-DiaryConfiguration -StorageLocation UserDataDirectory -DefaultDiary Personal

Creates configuration under the platform user-data directory and sets Personal
as the default diary.

.EXAMPLE
Set-DiaryConfiguration -ConfigDirectory '/tmp/des' -DiariesDirectory '/tmp/des/diaries' -DefaultDiary Work

Writes configuration to a custom location and sets Work as default.

.OUTPUTS
pscustomobject. The saved configuration object.
#>
function Set-DiaryConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateSet('OneDrive', 'Documents', 'UserDataDirectory')]
        [string]$StorageLocation = 'UserDataDirectory',

        [string]$ConfigDirectory,

        [string]$DiariesDirectory,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultDiary,

        [string]$ConfigurationPath
    )

    $baseRoot = switch ($StorageLocation) {
        'OneDrive' {
            if ([string]::IsNullOrWhiteSpace($env:OneDrive)) {
                throw 'OneDrive is not available on this system.'
            }

            $env:OneDrive
        }
        'Documents' {
            [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
        }
        'UserDataDirectory' {
            Get-UserDataDirectory
        }
    }

    if ([string]::IsNullOrWhiteSpace($ConfigDirectory)) {
        $ConfigDirectory = Join-Path -Path $baseRoot -ChildPath 'Diary-Entry-System'
    }

    if ([string]::IsNullOrWhiteSpace($DiariesDirectory)) {
        $DiariesDirectory = Join-Path -Path $ConfigDirectory -ChildPath 'Diaries'
    }

    if ([string]::IsNullOrWhiteSpace($ConfigurationPath)) {
        $ConfigurationPath = Join-Path -Path $ConfigDirectory -ChildPath 'DiaryConfig.json'
    }

    $configuration = [pscustomobject]@{
        ConfigVersion    = 1
        ConfigDirectory  = $ConfigDirectory
        DiariesDirectory = $DiariesDirectory
        DefaultDiary     = $DefaultDiary
    }

    if ($PSCmdlet.ShouldProcess($ConfigurationPath, 'Save diary configuration')) {
        Save-DiaryConfiguration -Configuration $configuration -ConfigurationPath $ConfigurationPath

        $Script:DiaryConfigurationPath = $ConfigurationPath
        $Script:DiaryConfiguration = $configuration
        $Script:CurrentDiary = $DefaultDiary

        $defaultDiaryPath = Get-DiaryFilePath -DiaryName $DefaultDiary
        if (-not (Test-Path -Path $defaultDiaryPath)) {
            '[]' | Set-Content -Path $defaultDiaryPath -Encoding UTF8
        }
    }

    return $configuration
} # Set-DiaryConfiguration
