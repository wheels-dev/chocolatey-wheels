@echo off
setlocal enabledelayedexpansion

set "TOOLS_DIR=%~dp0"
set "MODULE_SRC=%TOOLS_DIR%module"
set "MODULE_DST=%USERPROFILE%\.wheels\modules\wheels"
set "VERSION_SRC=%MODULE_SRC%\.module-version"
set "VERSION_DST=%MODULE_DST%\.module-version"

:: Copy module on first run or when version changes
if exist "%VERSION_SRC%" (
    set /p SRC_VER=<"%VERSION_SRC%"
    set "DST_VER="
    if exist "%VERSION_DST%" set /p DST_VER=<"%VERSION_DST%"
    if not "!SRC_VER!"=="!DST_VER!" (
        if not exist "%MODULE_DST%" mkdir "%MODULE_DST%"
        xcopy /E /I /Y "%MODULE_SRC%\*" "%MODULE_DST%\" >nul 2>&1
    )
)

endlocal & "%~dp0lucli.bat" %*
