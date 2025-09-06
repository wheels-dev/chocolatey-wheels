$ErrorActionPreference = 'Stop'

$packageName = 'wheels'

# Remove the wheels shim
Uninstall-BinFile -Name 'wheels'

Write-Host "Wheels CLI wrapper has been uninstalled." -ForegroundColor Green
Write-Host ""
Write-Host "Note: CommandBox and Wheels CLI tools remain installed." -ForegroundColor Yellow
Write-Host "CommandBox will remain installed and can be uninstalled separately if needed" -ForegroundColor Cyan