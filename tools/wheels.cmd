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
:: both paths must produce identical output.
:: Per-subcommand help (e.g. `wheels migrate --help`) is also intercepted
:: below — LuCLI's preprocessModuleHelp would otherwise drop the subcommand
:: name and route everything back to top-level help. See wheels-dev/wheels#2313.
if "%~2"=="" (
    if /i "%~1"=="--version" goto :wheels_version
    if /i "%~1"=="-v" goto :wheels_version
    if /i "%~1"=="--help" goto :wheels_help
    if /i "%~1"=="-h" goto :wheels_help
)

:: Per-subcommand --help dispatch. Scan all args for --help / -h, then
:: jump to the subcommand-specific label if the first arg is a known
:: subcommand. Unknown subcommands fall through to LuCLI.
set "SUB_HELP=0"
for %%a in (%*) do (
    if /i "%%~a"=="--help" set "SUB_HELP=1"
    if /i "%%~a"=="-h" set "SUB_HELP=1"
)
if "%SUB_HELP%"=="1" if not "%~2"=="" (
    if /i "%~1"=="new" goto :sub_help_new
    if /i "%~1"=="start" goto :sub_help_start
    if /i "%~1"=="stop" goto :sub_help_stop
    if /i "%~1"=="reload" goto :sub_help_reload
    if /i "%~1"=="generate" goto :sub_help_generate
    if /i "%~1"=="g" goto :sub_help_generate
    if /i "%~1"=="destroy" goto :sub_help_destroy
    if /i "%~1"=="d" goto :sub_help_destroy
    if /i "%~1"=="migrate" goto :sub_help_migrate
    if /i "%~1"=="seed" goto :sub_help_seed
    if /i "%~1"=="db" goto :sub_help_db
    if /i "%~1"=="test" goto :sub_help_test
    if /i "%~1"=="browser" goto :sub_help_browser
    if /i "%~1"=="console" goto :sub_help_console
    if /i "%~1"=="routes" goto :sub_help_routes
    if /i "%~1"=="info" goto :sub_help_info
    if /i "%~1"=="doctor" goto :sub_help_doctor
    if /i "%~1"=="validate" goto :sub_help_validate
    if /i "%~1"=="analyze" goto :sub_help_analyze
    if /i "%~1"=="stats" goto :sub_help_stats
    if /i "%~1"=="notes" goto :sub_help_notes
    if /i "%~1"=="packages" goto :sub_help_packages
    if /i "%~1"=="upgrade" goto :sub_help_upgrade
    if /i "%~1"=="deploy" goto :sub_help_deploy
    if /i "%~1"=="mcp" goto :sub_help_mcp
    if /i "%~1"=="version" goto :sub_help_version
    if /i "%~1"=="help" goto :sub_help_help
    if /i "%~1"=="create" goto :sub_help_create
    :: Unknown subcommand — fall through to LuCLI which will report it.
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

:sub_help_new
echo Usage: wheels new ^<name^> [options]
echo.
echo Scaffold a new Wheels application in .\^<name^>.
echo.
echo Options:
echo   --datasource=^<name^>    Default datasource name (default: wheels)
echo   --template=^<name^>      Template to use (default: app)
echo.
echo Examples:
echo   wheels new myapp
echo   wheels new blog --datasource=blogdb
endlocal
exit /b 0

:sub_help_start
echo Usage: wheels start [options]
echo.
echo Start the Wheels development server for the current project.
echo.
echo Refuses to start from a directory that does not look like a
echo Wheels project (no app\ + config\) to avoid creating phantom
echo server registrations under %%USERPROFILE%%\.wheels\servers\.
endlocal
exit /b 0

:sub_help_stop
echo Usage: wheels stop [--name ^<name^>] [--all]
echo.
echo Stop the Wheels development server registered for the current
echo directory. If no server is registered for cwd, lists all
echo running servers and suggests --name.
endlocal
exit /b 0

:sub_help_reload
echo Usage: wheels reload
echo.
echo Reload the running app -- clears caches, re-reads config,
echo re-runs onApplicationStart. Equivalent to visiting
echo /?reload=true^&password=wheels in a browser.
endlocal
exit /b 0

:sub_help_generate
echo Usage: wheels generate ^<type^> ^<name^> [attributes...]
echo.
echo Generate Wheels components.
echo.
echo Types:
echo   app           Create a new Wheels application (alias for 'wheels new')
echo   model         Generate a model CFC
echo   controller    Generate a controller CFC
echo   view          Generate a view template
echo   migration     Generate a database migration
echo   scaffold      Generate model + controller + views + migration + tests + routes
echo   api-resource  Generate API-only model + controller + migration + tests + routes
echo   route         Add a resource route to config\routes.cfm
echo   test          Generate a test spec file
echo   property      Add a property to an existing model
echo   helper        Generate a helper file
echo   snippet       Insert a code snippet
echo.
echo Examples:
echo   wheels generate model User firstName:string lastName:string
echo   wheels generate scaffold Post title:string body:text
echo   wheels generate migration addEmailToUsers
endlocal
exit /b 0

:sub_help_destroy
echo Usage: wheels destroy ^<type^> ^<name^>
echo        wheels destroy ^<name^>          (type defaults to 'resource')
echo.
echo Remove generated components. Requires --force to actually delete.
echo.
echo Types:
echo   resource    Remove model + controller + views + tests + route + migration (default)
echo   model       Remove model + test + generate drop-table migration
echo   controller  Remove controller + test
echo   view        Remove view directory (or single file with controller/view syntax)
echo.
echo Examples:
echo   wheels destroy User                   (remove the User resource)
echo   wheels destroy controller Products    (remove just the Products controller)
echo   wheels destroy model Product          (remove just the Product model)
echo   wheels destroy view products/index    (remove a single view)
endlocal
exit /b 0

:sub_help_migrate
echo Usage: wheels migrate [latest^|up^|down^|info]
echo.
echo Run database migrations.
echo.
echo Actions:
echo   latest   Apply all pending migrations (default)
echo   up       Apply the next pending migration
echo   down     Roll back the most recent migration
echo   info     Show migration status (applied vs pending)
echo.
echo Examples:
echo   wheels migrate
echo   wheels migrate latest
echo   wheels migrate info
endlocal
exit /b 0

:sub_help_seed
echo Usage: wheels seed [--environment=^<env^>] [--mode=^<auto^|generate^>] [--generate]
echo.
echo Run database seed files. Reads app\db\seeds.cfm (shared) followed
echo by app\db\seeds\^<environment^>.cfm (env-specific). Idempotent via
echo seedOnce().
echo.
echo Options:
echo   --environment=^<env^>     Run env-specific seed file (default: auto-detect)
echo   --mode=^<auto^|generate^>  Mode (default: auto)
echo   --generate              Use generated random data instead of seed files
echo.
echo Examples:
echo   wheels seed
echo   wheels seed --environment=development
echo   wheels seed --generate
endlocal
exit /b 0

:sub_help_db
echo Usage: wheels db ^<action^> [options]
echo.
echo Database management commands.
echo.
echo Actions:
echo   reset    Drop all tables, run migrations, reseed (requires --force)
echo   status   Show migration status (applied vs pending)
echo   version  Show current schema version
echo.
echo Examples:
echo   wheels db status
echo   wheels db status --pending
echo   wheels db reset --force
endlocal
exit /b 0

:sub_help_test
echo Usage: wheels test [options]
echo.
echo Run the WheelsTest BDD test suite.
echo.
echo Options:
echo   --filter=^<pattern^>     Run only specs matching the pattern
echo   --reporter=^<format^>    Reporter format: simple^|json^|tap (default: simple)
echo   --directory=^<path^>     Run only specs in this directory (dotted path)
echo.
echo Examples:
echo   wheels test
echo   wheels test --filter=UserSpec
echo   wheels test --directory=tests.specs.models
endlocal
exit /b 0

:sub_help_browser
echo Usage: wheels browser ^<action^>
echo.
echo Browser-based testing (Playwright).
echo.
echo Actions:
echo   setup    Download Playwright JARs and Chromium browser (~370MB, one-time)
echo.
echo Examples:
echo   wheels browser setup
endlocal
exit /b 0

:sub_help_console
echo Usage: wheels console
echo.
echo Open an interactive CFML REPL connected to your running app.
echo Server must be running (wheels start) first.
endlocal
exit /b 0

:sub_help_routes
echo Usage: wheels routes [--filter=^<pattern^>] [--format=^<text^|json^>]
echo.
echo Print the application's route table.
echo.
echo Options:
echo   --filter=^<pattern^>     Show only routes matching the pattern (name, path, controller)
echo   --format=^<text^|json^>   Output format (default: text)
echo.
echo Examples:
echo   wheels routes
echo   wheels routes --filter=user
endlocal
exit /b 0

:sub_help_info
echo Usage: wheels info
echo.
echo Show framework version, environment, and configuration details for
echo the current app.
endlocal
exit /b 0

:sub_help_doctor
echo Usage: wheels doctor [--verbose]
echo.
echo Diagnose project setup issues. Reports problems with directory
echo structure, missing config, mixin collisions, and other things
echo that can crash a Wheels app.
echo.
echo Options:
echo   --verbose    Show detailed diagnostic information
endlocal
exit /b 0

:sub_help_validate
echo Usage: wheels validate
echo.
echo Validate project structure and configuration. Returns non-zero
echo if issues are found.
endlocal
exit /b 0

:sub_help_analyze
echo Usage: wheels analyze [--target=^<all^|models^|controllers^|views^>] [--format=^<text^|json^>]
echo.
echo Static analysis of project code (anti-patterns, complexity
echo metrics, cross-engine warnings).
echo.
echo Options:
echo   --target=^<scope^>     Scope (default: all)
echo   --format=^<format^>    Output format (default: text)
endlocal
exit /b 0

:sub_help_stats
echo Usage: wheels stats [--format=^<text^|json^>]
echo.
echo Project statistics -- lines of code, model counts, test coverage
echo estimates.
endlocal
exit /b 0

:sub_help_notes
echo Usage: wheels notes [--tags=^<list^>]
echo.
echo Find TODO / FIXME / HACK / OPTIMIZE comments in your code.
echo.
echo Options:
echo   --tags=^<list^>    Comma-separated tag list (default: TODO,FIXME,HACK,OPTIMIZE)
endlocal
exit /b 0

:sub_help_packages
echo Usage: wheels packages ^<action^> [options]
echo.
echo Install, update, search Wheels packages from the registry
echo (default wheels-dev/wheels-packages).
echo.
echo Actions:
echo   list                                  List packages from the registry
echo   search ^<query^>                        Search by name/description/tag
echo   show ^<name^>                           Show details for a package
echo   install ^<name^>[@^<version^>]            Install (latest compat or pinned)
echo   install ^<name^> --force                Overwrite existing vendor\^<name^>
echo   update ^<name^> --yes                   Update a single package
echo   update --all --yes                    Update all installed packages
echo   remove ^<name^>                         Delete vendor\^<name^>
echo   registry refresh                      Bust the 24h registry cache
echo   registry info                         Show registry URL and cache state
echo.
echo Examples:
echo   wheels packages list
echo   wheels packages install wheels-sentry
echo   wheels packages update --all --yes
endlocal
exit /b 0

:sub_help_upgrade
echo Usage: wheels upgrade [--to=^<version^>] [--dry-run]
echo.
echo Upgrade the Wheels framework version in your project (vendor\wheels\).
echo.
echo Options:
echo   --to=^<version^>    Target version (default: latest stable)
echo   --dry-run         Print what would change without applying
endlocal
exit /b 0

:sub_help_deploy
echo Usage: wheels deploy [verb] [options]
echo.
echo Deploy your app to production via Kamal-compatible config
echo (config\deploy.yml). Ported from Basecamp Kamal.
echo.
echo Verbs (selection):
echo   init                 Scaffold config\deploy.yml + .kamal\secrets
echo   setup                One-time server bootstrap + first deploy
echo   (no verb)            Rolling deploy
echo   rollback ^<ver^>       Roll back to a previous version
echo   config               Print resolved config as YAML
echo   details              Aggregate app + proxy + accessory status
echo   app^|proxy^|accessory  Container lifecycle
echo   build^|registry       Image build/push
echo   prune^|lock^|secrets   Maintenance
echo.
echo For full subcommand reference: wheels deploy docs
echo.
echo Options:
echo   --dry-run    Print commands without executing
endlocal
exit /b 0

:sub_help_mcp
echo Usage: wheels mcp [setup^|wheels]
echo.
echo Configure the Wheels MCP server for AI assistants.
echo.
echo Actions:
echo   setup    Generate .mcp.json (Claude Code) and .opencode.json (OpenCode) in cwd
echo   wheels   Run the stdio MCP server (used by AI IDEs, not invoked manually)
echo.
echo Examples:
echo   wheels mcp setup
endlocal
exit /b 0

:sub_help_version
echo Usage: wheels version
echo.
echo Show the Wheels CLI version banner. Same as 'wheels --version'.
endlocal
exit /b 0

:sub_help_help
echo Usage: wheels help
echo.
echo Show top-level help. Same as 'wheels --help'.
echo.
echo For per-subcommand help: wheels ^<command^> --help
endlocal
exit /b 0

:sub_help_create
echo Usage: wheels create ^<type^> ^<name^> [options]
echo.
echo Create deployment scaffolding (config\deploy.yml, etc.).
echo.
echo For details: wheels deploy init --help
endlocal
exit /b 0
