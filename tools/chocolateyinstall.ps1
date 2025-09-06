$ErrorActionPreference = 'Stop'

$packageName = 'wheels'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Create the wheels.bat wrapper script
$batchContent = @'
@echo off
REM Wheels CLI wrapper for CommandBox
REM Passes all arguments to 'box wheels'

REM Check if CommandBox is available
where box >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Error: CommandBox is required but not found in PATH
    echo Please install CommandBox from https://www.ortussolutions.com/products/commandbox
    exit /b 1
)

REM Pass all arguments to box wheels
box wheels %*
'@

$batchFile = Join-Path $toolsDir "wheels.bat"
$batchContent | Out-File -FilePath $batchFile -Encoding ASCII

Write-Host "Created wheels.bat wrapper script at: $batchFile"

# Create the wheels.ps1 PowerShell script as well for PowerShell users
$psContent = @'
# Wheels CLI wrapper for CommandBox
# Passes all arguments to 'box wheels'

# Check if CommandBox is available
if (-not (Get-Command "box" -ErrorAction SilentlyContinue)) {
    Write-Error "CommandBox is required but not found in PATH. Please install CommandBox from https://www.ortussolutions.com/products/commandbox"
    exit 1
}

# Pass all arguments to box wheels
& box wheels @args
'@

$psFile = Join-Path $toolsDir "wheels.ps1"
$psContent | Out-File -FilePath $psFile -Encoding UTF8

Write-Host "Created wheels.ps1 PowerShell script at: $psFile"

# Install the batch file to make it available in PATH
# The tools directory is automatically added to PATH by Chocolatey

Write-Host "Wheels CLI wrapper installed successfully!"
Write-Host "You can now use 'wheels' command from any command prompt or PowerShell session."
Write-Host ""
Write-Host "Example usage:"
Write-Host "  wheels generate model User"
Write-Host "  wheels migrate up"
Write-Host "  wheels server start"
Write-Host "  wheels --help"