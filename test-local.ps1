# Test script for local installation of Wheels Chocolatey package
param(
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

if ($Uninstall) {
    Write-Host "Uninstalling wheels package..." -ForegroundColor Yellow
    choco uninstall wheels -y 2>$null
    Write-Host "Done."
    exit
}

Write-Host "Testing local installation of Wheels package (LuCLI)" -ForegroundColor Green
Write-Host ""

# Pre-check: LuCLI must be available
if (-not (Get-Command "lucli" -ErrorAction SilentlyContinue)) {
    Write-Warning "LuCLI is not installed. Install it first: choco install lucli"
    Write-Host "Continuing with package build only..." -ForegroundColor Yellow
}

# Build the package first
Write-Host "Building the package..." -ForegroundColor Cyan
& "$PSScriptRoot\build.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build package"
    exit 1
}

Write-Host ""
Write-Host "Installing the package locally..." -ForegroundColor Cyan

# Uninstall if already installed
choco uninstall wheels -y 2>$null

# Install from current directory
$nupkg = Get-ChildItem -Filter "*.nupkg" | Select-Object -First 1
if ($nupkg) {
    choco install wheels --source "." -y
} else {
    Write-Error "No .nupkg file found. Run build.ps1 first."
    exit 1
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Installation successful!" -ForegroundColor Green
    Write-Host ""

    # Test the installation
    Write-Host "Testing the wheels command..." -ForegroundColor Cyan

    $wheelsPath = Get-Command wheels -ErrorAction SilentlyContinue
    if ($wheelsPath) {
        Write-Host "Wheels command found at: $($wheelsPath.Source)" -ForegroundColor Green

        Write-Host ""
        Write-Host "Running 'wheels --version':" -ForegroundColor Yellow
        wheels --version

        Write-Host ""
        Write-Host "Test completed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now use the 'wheels' command. Examples:" -ForegroundColor Yellow
        Write-Host "  wheels generate model User" -ForegroundColor Cyan
        Write-Host "  wheels migrate up" -ForegroundColor Cyan
        Write-Host "  wheels server start" -ForegroundColor Cyan
        Write-Host "  wheels --help" -ForegroundColor Cyan
    } else {
        Write-Warning "Wheels command not found in PATH. You may need to restart your terminal."
    }

    Write-Host ""
    Write-Host "To uninstall the test installation, run:" -ForegroundColor Yellow
    Write-Host "  .\test-local.ps1 -Uninstall" -ForegroundColor Cyan
} else {
    Write-Error "Installation failed"
    exit 1
}
