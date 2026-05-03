function New-ProgressItem {
    [CmdletBinding()]
    param (
        [datetime]$DateOfProgress = (Get-Date),

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ShortDesc,

        [AllowNull()]
        [string]$Desc,

        [ValidateRange(0, 1000)]
        [double]$HoursWorked = 0,

        [string]$JSONPath = (Get-JSONPath)
    )

    $jsonText = Get-Content -Path $JSONPath -Raw
    $progressEvents = @()

    if (-not [string]::IsNullOrWhiteSpace($jsonText)) {
        $parsed = $jsonText | ConvertFrom-Json
        $progressEvents = @($parsed)
    }

    $progressEvents += [PSCustomObject]@{
        Title          = $Title
        ShortDesc      = $ShortDesc
        Desc           = $Desc
        DateEntered    = (Get-Date)
        DateOfProgress = (Get-Date -Date $DateOfProgress -Format 'MM-dd-yyyy')
        HoursWorked    = if ($HoursWorked -gt 0) { $HoursWorked } else { $null }
    }

    $progressEvents | ConvertTo-Json -Depth 10 | Set-Content -Path $JSONPath -Encoding UTF8
} # New-ProgressItem
