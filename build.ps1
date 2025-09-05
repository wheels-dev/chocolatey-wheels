# Build script for Wheels Chocolatey package
param(
    [string]$Version = "1.0.5",
    [switch]$Push,
    [string]$ApiKey = $env:CHOCOLATEY_API_KEY,
    [string]$Source = "https://push.chocolatey.org/"
)

$ErrorActionPreference = 'Stop'

Write-Host "Building Wheels Chocolatey package v$Version" -ForegroundColor Green

# Update version in nuspec if provided
if ($Version) {
    $nuspecPath = Join-Path $PSScriptRoot "wheels.nuspec"
    $nuspecContent = Get-Content $nuspecPath -Raw
    $nuspecContent = $nuspecContent -replace '<version>.*?</version>', "<version>$Version</version>"
    Set-Content -Path $nuspecPath -Value $nuspecContent -NoNewline
    Write-Host "Updated version to $Version in nuspec file" -ForegroundColor Yellow
}

# Clean up any existing nupkg files
Remove-Item *.nupkg -ErrorAction SilentlyContinue

# Pack the package
Write-Host "Packing the Chocolatey package..." -ForegroundColor Cyan
choco pack

# Find the generated package
$packageFile = Get-ChildItem -Filter "*.nupkg" | Select-Object -First 1

if ($packageFile) {
    Write-Host "Package created: $($packageFile.Name)" -ForegroundColor Green
    
    if ($Push) {
        if (-not $ApiKey) {
            Write-Error "API key is required to push the package. Set CHOCOLATEY_API_KEY environment variable or use -ApiKey parameter."
            exit 1
        }
        
        Write-Host "Pushing package to Chocolatey..." -ForegroundColor Cyan
        choco push $packageFile.Name --source $Source --api-key $ApiKey
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Package pushed successfully!" -ForegroundColor Green
        } else {
            Write-Error "Failed to push package to Chocolatey"
            exit 1
        }
    } else {
        Write-Host ""
        Write-Host "To test the package locally, run:" -ForegroundColor Yellow
        Write-Host "  choco install wheels -s . -y" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To push the package to Chocolatey, run:" -ForegroundColor Yellow
        Write-Host "  .\build.ps1 -Push -ApiKey YOUR_API_KEY" -ForegroundColor Cyan
    }
} else {
    Write-Error "Failed to create package"
    exit 1
}