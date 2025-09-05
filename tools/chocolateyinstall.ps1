$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$packageName = 'wheels'

# Check if CommandBox is installed
$commandboxInstalled = $false
try {
    $commandboxPath = Get-Command box -ErrorAction SilentlyContinue
    if ($commandboxPath) {
        $commandboxInstalled = $true
        Write-Host "CommandBox found at: $($commandboxPath.Source)"
    }
} catch {
    # CommandBox not found
}

if (-not $commandboxInstalled) {
    Write-Host "CommandBox is required but not installed." -ForegroundColor Yellow
    Write-Host "Installing CommandBox..." -ForegroundColor Green
    
    # Install CommandBox as a dependency
    Install-ChocolateyPackage 'commandbox' -PackageParameters ''
    
    # Refresh environment variables
    Update-SessionEnvironment
    
    # Verify CommandBox installation
    try {
        $commandboxPath = Get-Command box -ErrorAction Stop
        Write-Host "CommandBox installed successfully at: $($commandboxPath.Source)" -ForegroundColor Green
    } catch {
        throw "Failed to install CommandBox. Please install it manually: choco install commandbox"
    }
}

# Create the wheels wrapper script
$wheelsScriptContent = @'
@echo off
setlocal enabledelayedexpansion

:: Wheels CLI wrapper for CommandBox on Windows
:: Passes all arguments to 'box wheels'

:: Check if CommandBox is available
where box >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: CommandBox is required but not found in PATH
    echo Please install CommandBox: choco install commandbox
    exit /b 1
)

:: Check if Wheels CLI tools are installed
box help wheels 2>&1 | findstr /C:"Command.*not found" >nul
if %ERRORLEVEL% EQU 0 (
    echo Installing Wheels CLI tools for CommandBox...
    box install wheels-cli
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Failed to install Wheels CLI tools
        echo Please try manually: box install wheels-cli
        exit /b 1
    )
    echo Wheels CLI tools installed successfully
)

:: Handle special cases for help and version
if "%~1"=="--help" goto :show_help
if "%~1"=="-h" goto :show_help
if "%~1"=="--version" goto :show_version
if "%~1"=="-v" goto :show_version
goto :run_command

:show_help
box help wheels
exit /b 0

:show_version
echo wheels wrapper version 1.0.5
echo Powered by:
box version
exit /b 0

:run_command
:: Convert command line arguments from standard --parameter=value format
:: to CommandBox parameter=value format
set "converted_args="
set "first=1"

:parse_loop
if "%~1"=="" goto :execute

set "arg=%~1"
set "converted_arg="

:: Check for --parameter=value format
echo !arg! | findstr /r "^--[^=]*=.*" >nul
if %ERRORLEVEL% EQU 0 (
    :: Remove the -- prefix
    set "converted_arg=!arg:~2!"
    goto :add_arg
)

:: Check for --noFlag format (convert to flag=false)
echo !arg! | findstr /r "^--no[A-Z].*" >nul
if %ERRORLEVEL% EQU 0 (
    :: Extract flag name and convert to lowercase first letter
    set "flag=!arg:~4!"
    :: Convert first letter to lowercase manually
    set "firstChar=!flag:~0,1!"
    set "restChars=!flag:~1!"
    
    :: Lowercase conversion for common letters
    if "!firstChar!"=="A" set "firstChar=a"
    if "!firstChar!"=="B" set "firstChar=b"
    if "!firstChar!"=="C" set "firstChar=c"
    if "!firstChar!"=="D" set "firstChar=d"
    if "!firstChar!"=="E" set "firstChar=e"
    if "!firstChar!"=="F" set "firstChar=f"
    if "!firstChar!"=="G" set "firstChar=g"
    if "!firstChar!"=="H" set "firstChar=h"
    if "!firstChar!"=="I" set "firstChar=i"
    if "!firstChar!"=="J" set "firstChar=j"
    if "!firstChar!"=="K" set "firstChar=k"
    if "!firstChar!"=="L" set "firstChar=l"
    if "!firstChar!"=="M" set "firstChar=m"
    if "!firstChar!"=="N" set "firstChar=n"
    if "!firstChar!"=="O" set "firstChar=o"
    if "!firstChar!"=="P" set "firstChar=p"
    if "!firstChar!"=="Q" set "firstChar=q"
    if "!firstChar!"=="R" set "firstChar=r"
    if "!firstChar!"=="S" set "firstChar=s"
    if "!firstChar!"=="T" set "firstChar=t"
    if "!firstChar!"=="U" set "firstChar=u"
    if "!firstChar!"=="V" set "firstChar=v"
    if "!firstChar!"=="W" set "firstChar=w"
    if "!firstChar!"=="X" set "firstChar=x"
    if "!firstChar!"=="Y" set "firstChar=y"
    if "!firstChar!"=="Z" set "firstChar=z"
    
    set "converted_arg=!firstChar!!restChars!=false"
    goto :add_arg
)

:: Check for --flag format (convert to flag=true)
echo !arg! | findstr /r "^--[a-zA-Z].*" >nul
if %ERRORLEVEL% EQU 0 (
    set "converted_arg=!arg:~2!=true"
    goto :add_arg
)

:: Pass through other arguments unchanged
set "converted_arg=!arg!"

:add_arg
if "!first!"=="1" (
    set "converted_args=!converted_arg!"
    set "first=0"
) else (
    set "converted_args=!converted_args! !converted_arg!"
)

shift
goto :parse_loop

:execute
:: Pass converted arguments to box wheels
box wheels !converted_args!
exit /b %ERRORLEVEL%
'@

$wheelsScriptPath = Join-Path $toolsDir "wheels.cmd"
Set-Content -Path $wheelsScriptPath -Value $wheelsScriptContent -Encoding UTF8

# Create a shim for the wheels command
Install-BinFile -Name 'wheels' -Path $wheelsScriptPath

Write-Host "Wheels CLI wrapper installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now use 'wheels' command from any command prompt or PowerShell window." -ForegroundColor Green
Write-Host "Example: wheels generate model User" -ForegroundColor Cyan
Write-Host ""

# Check if Wheels CLI is installed in CommandBox
try {
    $wheelsCliCheck = & box help wheels 2>&1
    if ($wheelsCliCheck -match "Command.*not found") {
        Write-Host "Note: Wheels CLI tools will be automatically installed on first use." -ForegroundColor Yellow
    } else {
        Write-Host "Wheels CLI tools are already installed in CommandBox." -ForegroundColor Green
    }
} catch {
    Write-Host "Note: Wheels CLI tools will be checked and installed on first use." -ForegroundColor Yellow
}