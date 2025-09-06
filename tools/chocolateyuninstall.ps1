$ErrorActionPreference = 'Stop'

$packageName = 'wheels'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Remove the wrapper scripts
$batchFile = Join-Path $toolsDir "wheels.bat"
$psFile = Join-Path $toolsDir "wheels.ps1"

if (Test-Path $batchFile) {
    Remove-Item $batchFile -Force
    Write-Host "Removed wheels.bat"
}

if (Test-Path $psFile) {
    Remove-Item $psFile -Force
    Write-Host "Removed wheels.ps1"
}

Write-Host "Wheels CLI wrapper has been uninstalled."