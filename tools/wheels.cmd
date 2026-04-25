@echo off
setlocal enabledelayedexpansion

set "TOOLS_DIR=%~dp0"
set "MODULE_SRC=%TOOLS_DIR%module"
set "MODULE_DST=%USERPROFILE%\.wheels\modules\wheels"
set "VERSION_SRC=%MODULE_SRC%\.module-version"
set "VERSION_DST=%MODULE_DST%\.module-version"
set "SQLITE_JDBC_SRC=%TOOLS_DIR%lib\sqlite-jdbc-3.49.1.0.jar"

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

:: Drop sqlite-jdbc into LuCLI's extracted Lucee lib/ext/ if missing. The
:: express dir only exists after first LuCLI run, so this is a no-op on the
:: very first invocation and self-heals on every run after.
if exist "%SQLITE_JDBC_SRC%" (
    if exist "%USERPROFILE%\.wheels\express\" (
        for /D %%V in ("%USERPROFILE%\.wheels\express\*") do (
            if exist "%%V\lib\ext\" (
                if not exist "%%V\lib\ext\sqlite-jdbc-3.49.1.0.jar" (
                    copy /Y /B "%SQLITE_JDBC_SRC%" "%%V\lib\ext\" >nul 2>&1
                )
            )
        )
    )
)

endlocal & set "LUCLI_HOME=%USERPROFILE%\.wheels" & "%~dp0lucli.bat" %*
