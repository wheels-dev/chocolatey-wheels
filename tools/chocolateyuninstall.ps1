$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Clean up downloaded files
$filesToRemove = @("lucli.bat", "wheels-module.zip")
foreach ($file in $filesToRemove) {
    $path = Join-Path $toolsDir $file
    if (Test-Path $path) { Remove-Item $path -Force }
}

$moduleDir = Join-Path $toolsDir "module"
if (Test-Path $moduleDir) { Remove-Item $moduleDir -Recurse -Force }

$libDir = Join-Path $toolsDir "lib"
if (Test-Path $libDir) { Remove-Item $libDir -Recurse -Force }

Write-Host "Wheels CLI uninstalled." -ForegroundColor Green
Write-Host "Note: ~/.wheels/ directory was not removed. Delete it manually if desired." -ForegroundColor Yellow
