Set-StrictMode -Version Latest

$global:RepoRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$global:ManifestPath = Join-Path -Path $global:RepoRoot -ChildPath 'Diary-Entry-System.psd1'
$global:ModuleName = 'Diary-Entry-System'

function global:Invoke-ExternalPwsh {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Code,

        [AllowEmptyString()]
        [string]$StdIn = ''
    )

    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($Code))
    $currentPwshPath = (Get-Process -Id $PID).Path

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $currentPwshPath
    $startInfo.Arguments = "-NoLogo -NoProfile -EncodedCommand $encoded"
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    $null = $process.Start()

    $process.StandardInput.Write($StdIn)
    $process.StandardInput.Close()

    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    [pscustomobject]@{
        ExitCode = $process.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
    }
}
