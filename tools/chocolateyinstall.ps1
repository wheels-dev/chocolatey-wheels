$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$lucliVersion = "0.3.7"
$moduleVersion = "4.0.0-SNAPSHOT+1508"

# Download LuCLI Windows launcher
$lucliUrl = "https://github.com/cybersonic/LuCLI/releases/download/v${lucliVersion}/lucli-${lucliVersion}.bat"
$lucliPath = Join-Path $toolsDir "lucli.bat"
Invoke-WebRequest -Uri $lucliUrl -OutFile $lucliPath -UseBasicParsing

# Download Wheels module
$moduleUrl = "https://github.com/wheels-dev/wheels/releases/download/v${moduleVersion}/wheels-module-${moduleVersion}.zip"
$modulePath = Join-Path $toolsDir "wheels-module.zip"
Invoke-WebRequest -Uri $moduleUrl -OutFile $modulePath -UseBasicParsing

# Extract module to tools/module/
$moduleDir = Join-Path $toolsDir "module"
if (Test-Path $moduleDir) { Remove-Item $moduleDir -Recurse -Force }
Expand-Archive -Path $modulePath -DestinationPath $moduleDir -Force
Remove-Item $modulePath -Force

# Write version marker
Set-Content -Path (Join-Path $moduleDir ".module-version") -Value $moduleVersion

Write-Host "Wheels CLI installed successfully!" -ForegroundColor Green
Write-Host "Run 'wheels --version' to verify." -ForegroundColor Cyan


