function Initialize-DiaryConfiguration {
    [CmdletBinding()]
    param()

    $existingConfigurationVariable = Get-Variable -Scope Script -Name DiaryConfiguration -ErrorAction SilentlyContinue
    if ($null -ne $existingConfigurationVariable -and $null -ne $existingConfigurationVariable.Value) {
        return
    }

    $configurationPath = Get-DiaryConfigurationPath
    $configuration = $null

    if (Test-Path -Path $configurationPath) {
        try {
            $configuration = Get-Content -Path $configurationPath -Raw | ConvertFrom-Json
        } catch {
            Write-Host -ForegroundColor Yellow 'Existing configuration is invalid and will be recreated.'
        }
    }

    if ($null -eq $configuration) {
        Write-Host 'Diary configuration was not found. Initial setup is required.'

        $locationOptions = @()
        if (-not [string]::IsNullOrWhiteSpace($env:OneDrive)) {
            $locationOptions += [pscustomobject]@{ Label = 'OneDrive'; Path = $env:OneDrive }
        }

        $documentsPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
        if (-not [string]::IsNullOrWhiteSpace($documentsPath)) {
            $locationOptions += [pscustomobject]@{ Label = 'Documents'; Path = $documentsPath }
        }

        $locationOptions += [pscustomobject]@{ Label = 'User Data Directory'; Path = (Get-UserDataDirectory) }

        Write-Host 'Select storage base location:'
        for ($i = 0; $i -lt $locationOptions.Count; $i++) {
            Write-Host ("  {0}. {1} ({2})" -f ($i + 1), $locationOptions[$i].Label, $locationOptions[$i].Path)
        }

        $selection = 0
        while ($selection -lt 1 -or $selection -gt $locationOptions.Count) {
            $selectionText = Read-Host -Prompt 'Selection'
            [void][int]::TryParse($selectionText, [ref]$selection)
        }

        $selectedRoot = $locationOptions[$selection - 1].Path
        $defaultConfigDirectory = Join-Path -Path $selectedRoot -ChildPath 'Diary-Entry-System'
        $configDirectory = Read-Host -Prompt "Configuration directory ($defaultConfigDirectory)"
        if ([string]::IsNullOrWhiteSpace($configDirectory)) {
            $configDirectory = $defaultConfigDirectory
        }

        $defaultDiariesDirectory = Join-Path -Path $configDirectory -ChildPath 'Diaries'
        $diariesDirectory = Read-Host -Prompt "Diaries directory ($defaultDiariesDirectory)"
        if ([string]::IsNullOrWhiteSpace($diariesDirectory)) {
            $diariesDirectory = $defaultDiariesDirectory
        }

        $defaultDiary = ''
        while ([string]::IsNullOrWhiteSpace($defaultDiary)) {
            $defaultDiary = Read-Host -Prompt 'Default diary name'
        }

        $configurationPath = Join-Path -Path $configDirectory -ChildPath 'DiaryConfig.json'
        $configuration = [pscustomobject]@{
            ConfigVersion    = 1
            ConfigDirectory  = $configDirectory
            DiariesDirectory = $diariesDirectory
            DefaultDiary     = $defaultDiary
        }

        Save-DiaryConfiguration -Configuration $configuration -ConfigurationPath $configurationPath
    }

    if ([string]::IsNullOrWhiteSpace($configuration.DiariesDirectory)) {
        throw 'Configuration is missing DiariesDirectory.'
    }

    if (-not (Test-Path -Path $configuration.DiariesDirectory)) {
        New-Item -Path $configuration.DiariesDirectory -ItemType Directory -Force | Out-Null
    }

    $Script:DiaryConfigurationPath = $configurationPath
    $Script:DiaryConfiguration = $configuration

    if ([string]::IsNullOrWhiteSpace($Script:DiaryConfiguration.DefaultDiary)) {
        Write-Host -ForegroundColor Yellow 'No default diary is configured.'
        [void](Select-Diary -SetAsDefault)
    }

    if ([string]::IsNullOrWhiteSpace($Script:DiaryConfiguration.DefaultDiary)) {
        throw 'A default diary is required to continue.'
    }

    $Script:CurrentDiary = $Script:DiaryConfiguration.DefaultDiary
    $defaultDiaryPath = Get-DiaryFilePath -DiaryName $Script:CurrentDiary
    if (-not (Test-Path -Path $defaultDiaryPath)) {
        '[]' | Set-Content -Path $defaultDiaryPath -Encoding UTF8
    }
} # Initialize-DiaryConfiguration
