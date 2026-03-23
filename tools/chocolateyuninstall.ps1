$ErrorActionPreference = 'Stop'

$packageName = 'wheels'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Remove wrapper scripts
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

# Uninstall the Wheels module from LuCLI
if (Get-Command "lucli" -ErrorAction SilentlyContinue) {
    Write-Host "Removing Wheels CLI module from LuCLI..." -ForegroundColor Cyan
    lucli modules uninstall wheels 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Wheels module removed from LuCLI"
    } else {
        Write-Warning "Could not remove Wheels module from LuCLI (may already be removed)"
    }
}

Write-Host "Wheels CLI wrapper has been uninstalled."
