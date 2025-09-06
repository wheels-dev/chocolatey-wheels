@echo off
setlocal enabledelayedexpansion

:: Wheels CLI wrapper for CommandBox on Windows
:: Passes all arguments to 'box wheels'

:: Check if CommandBox is available
where box >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: CommandBox is required but not found in PATH
    echo Please install CommandBox manually if this dependency was not installed
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
:: Check if first argument is "server" and handle it specially
set "firstArg="
for /f "tokens=1" %%a in ("!converted_args!") do set "firstArg=%%a"

if /i "!firstArg!"=="server" (
    :: Remove "server" from the converted_args and pass directly to box server
    set "serverArgs=!converted_args:server=!"
    :: Trim leading space if any
    for /f "tokens=* delims= " %%a in ("!serverArgs!") do set "serverArgs=%%a"
    box server !serverArgs!
) else (
    :: Pass all arguments to box wheels as before
    box wheels !converted_args!
)
exit /b %ERRORLEVEL%