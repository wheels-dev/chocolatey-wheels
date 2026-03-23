@echo off
:: Wheels CLI wrapper — passes all arguments to LuCLI
:: LuCLI handles CLI conventions natively (no argument conversion needed)

where lucli >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: LuCLI is required but not found in PATH
    echo Install via: choco install lucli
    exit /b 1
)

lucli wheels %*
exit /b %ERRORLEVEL%
