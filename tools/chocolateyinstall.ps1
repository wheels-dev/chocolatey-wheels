$ErrorActionPreference = 'Stop'

$packageName = 'wheels'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$moduleUrl = 'https://github.com/wheels-dev/wheels/archive/refs/heads/develop.tar.gz'

# Verify LuCLI is available (installed as a dependency)
if (-not (Get-Command "lucli" -ErrorAction SilentlyContinue)) {
    Write-Error "LuCLI is required but not found in PATH. The lucli dependency should have been installed automatically."
    exit 1
}

# Install the Wheels module for LuCLI
Write-Host "Installing Wheels CLI module for LuCLI..." -ForegroundColor Cyan
lucli modules install wheels --url $moduleUrl
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Failed to install Wheels module via LuCLI. The 'wheels' command will attempt module installation on first use."
}

# Create wheels.bat wrapper for cmd.exe users
$batchContent = @'
@echo off
lucli wheels %*
'@
$batchFile = Join-Path $toolsDir "wheels.bat"
$batchContent | Out-File -FilePath $batchFile -Encoding ASCII
Write-Host "Created wheels.bat wrapper at: $batchFile"

# Create wheels.ps1 wrapper for PowerShell users
$psContent = @'
if (-not (Get-Command "lucli" -ErrorAction SilentlyContinue)) {
    Write-Error "LuCLI is required but not found in PATH. Install via: choco install lucli"
    exit 1
}
& lucli wheels @args
'@
$psFile = Join-Path $toolsDir "wheels.ps1"
$psContent | Out-File -FilePath $psFile -Encoding UTF8
Write-Host "Created wheels.ps1 wrapper at: $psFile"

Write-Host ""
Write-Host "Wheels CLI installed successfully! (powered by LuCLI)" -ForegroundColor Green
Write-Host ""
Write-Host "Example usage:"
Write-Host "  wheels generate model User"
Write-Host "  wheels migrate up"
Write-Host "  wheels server start"
Write-Host "  wheels --help"
