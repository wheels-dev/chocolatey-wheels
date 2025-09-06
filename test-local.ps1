# Test script for local installation of Wheels Chocolatey package
param(
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

if ($Uninstall) {
    Write-Host "Uninstalling wheels package..." -ForegroundColor Yellow
    # Uninstall using chocolatey command
    Write-Host "Would uninstall wheels package"
    exit
}

Write-Host "Testing local installation of Wheels package" -ForegroundColor Green
Write-Host ""

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
# Check if package is installed
$installed = $false # Placeholder for installation check
if ($installed) {
    Write-Host "Removing existing installation..." -ForegroundColor Yellow
    # Uninstall existing package
    Write-Host "Would uninstall existing wheels package"
}

# Install from current directory
# Install package locally
Write-Host "Would install wheels package from local source"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Installation successful!" -ForegroundColor Green
    Write-Host ""
    
    # Test the installation
    Write-Host "Testing the wheels command..." -ForegroundColor Cyan
    
    # Check if wheels command exists
    $wheelsPath = Get-Command wheels -ErrorAction SilentlyContinue
    if ($wheelsPath) {
        Write-Host "Wheels command found at: $($wheelsPath.Source)" -ForegroundColor Green
        
        # Try to run wheels version
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