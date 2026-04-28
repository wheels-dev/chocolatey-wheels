@echo off
setlocal enabledelayedexpansion

set "TOOLS_DIR=%~dp0"
set "MODULE_SRC=%TOOLS_DIR%module"
set "MODULE_DST=%USERPROFILE%\.wheels\modules\wheels"
set "FRAMEWORK_SRC=%TOOLS_DIR%framework\wheels"
set "FRAMEWORK_DST=%USERPROFILE%\.wheels\modules\wheels\vendor\wheels"
set "VERSION_SRC=%MODULE_SRC%\.module-version"
set "VERSION_DST=%MODULE_DST%\.module-version"
set "SQLITE_JDBC_SRC=%TOOLS_DIR%lib\sqlite-jdbc-3.49.1.0.jar"

:: Intercept --version and --help before lucli.bat sees them. picocli treats
:: these as usageHelp/versionHelp flags and short-circuits during arg parsing,
:: so they would never reach our module's version()/showHelp() if we exec'd
:: LuCLI. Keep in sync with cli/lucli/Module.cfc's version() and showHelp() —
:: both paths must produce identical output. Subcommand help (e.g.
:: `wheels migrate --help`) is left to fall through to LuCLI.
if "%~2"=="" (
    if /i "%~1"=="--version" goto :wheels_version
    if /i "%~1"=="-v" goto :wheels_version
    if /i "%~1"=="--help" goto :wheels_help
    if /i "%~1"=="-h" goto :wheels_help
)

:: Copy module + framework source on first run or when version changes
if exist "%VERSION_SRC%" (
    set /p SRC_VER=<"%VERSION_SRC%"
    set "DST_VER="
    if exist "%VERSION_DST%" set /p DST_VER=<"%VERSION_DST%"
    if not "!SRC_VER!"=="!DST_VER!" (
        if not exist "%MODULE_DST%" mkdir "%MODULE_DST%"
        xcopy /E /I /Y "%MODULE_SRC%\*" "%MODULE_DST%\" >nul 2>&1
        if exist "%FRAMEWORK_SRC%" (
            if not exist "%FRAMEWORK_DST%" mkdir "%FRAMEWORK_DST%"
            xcopy /E /I /Y "%FRAMEWORK_SRC%\*" "%FRAMEWORK_DST%\" >nul 2>&1
        )
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
goto :eof

:wheels_version
set "VER=unknown"
if exist "%VERSION_DST%" set /p VER=<"%VERSION_DST%"
if "%VER%"=="unknown" if exist "%VERSION_SRC%" set /p VER=<"%VERSION_SRC%"
echo Wheels Version: %VER%
echo.
echo  __        ___               _
echo  \ \      / / ^|__   ___  ___^| ^|___
echo   \ \ /\ / /^| '_ \ / _ \/ _ \ / __^|
echo    \ V  V / ^| ^| ^| ^|  __/  __/ \__ \
echo     \_/\_/  ^|_^| ^|_^|\___^|\___^|_^|___/
echo.
echo https://wheels.dev
endlocal
exit /b 0

:wheels_help
set "VER=unknown"
if exist "%VERSION_DST%" set /p VER=<"%VERSION_DST%"
if "%VER%"=="unknown" if exist "%VERSION_SRC%" set /p VER=<"%VERSION_SRC%"
echo Wheels CLI %VER%
echo   CFML MVC framework -- code generation, migrations, testing, server management
echo.
echo Usage:
echo   wheels ^<command^> [options]
echo.
echo Getting Started:
echo   new ^<name^>          Scaffold a new Wheels application
echo   start               Start the dev server
echo   stop                Stop the dev server
echo   reload              Reload the running app
echo.
echo Code Generation:
echo   generate            Generate model, controller, scaffold, migration, etc.
echo   destroy (or d)      Remove generated files
echo.
echo Database:
echo   migrate             Run database migrations (latest, up, down, info)
echo   seed                Run database seeds
echo   db                  Database management (reset, status, version)
echo.
echo Testing ^& Inspection:
echo   test                Run the test suite
echo   browser             Browser-based tests (Playwright)
echo   console             Open an interactive CFML REPL connected to your app
echo   routes              Print the route table
echo   info                Show framework version, environment, configuration
echo   doctor              Diagnose project setup issues
echo   validate            Validate project structure and configuration
echo   analyze             Static analysis of project code
echo   stats               Project statistics (lines of code, model counts, etc.)
echo   notes               Find TODO / FIXME / HACK / OPTIMIZE comments
echo.
echo Packages ^& Deployment:
echo   packages            Install, update, search Wheels packages
echo   upgrade             Upgrade the Wheels framework version in your project
echo   deploy              Deploy your app (Kamal-compatible)
echo.
echo Other:
echo   mcp                 Configure Wheels MCP server for AI assistants
echo   version             Show Wheels CLI version
echo   help                Show this help
echo.
echo For command-specific help: wheels ^<command^> --help
echo.
echo More info: https://guides.wheels.dev
endlocal
exit /b 0
