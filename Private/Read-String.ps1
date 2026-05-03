function Read-String {
    [CmdletBinding()]
    param(
        [ValidateRange(1, 1048576)]
        [int]$MaxLength = 65536,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Prompt
    )

    $str = ''
    Write-Host -NoNewline ($Prompt + ': ')
    $inputStream = [System.Console]::OpenStandardInput($MaxLength)
    $bytes = [byte[]]::new($MaxLength)

    while ($true) {
        $len = $inputStream.Read($bytes, 0, $MaxLength)
        if ($len -le 0) {
            return $str
        }

        $str += [string]::new($bytes, 0, $len)
        if ($str.EndsWith("`r`n") -or $str.EndsWith("`n")) {
            return $str.TrimEnd("`r", "`n")
        }
    }
} # Read-String [kganjam - https://github.com/PowerShell/PowerShell/issues/16555]
