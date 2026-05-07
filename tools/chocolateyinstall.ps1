$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$lucliVersion = "0.3.7"
$moduleVersion = "4.0.0-SNAPSHOT+1733"
$sqliteJdbcVersion = "3.49.1.0"

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

# Download Wheels framework source (vendor/wheels/). Mirrors the homebrew
# formula's `wheels_core` resource — required so that ${HOME}/.wheels/modules/
# wheels/vendor/wheels/ is populated. The zip's top-level entry is "wheels/",
# which Expand-Archive preserves (unlike brew's resource.stage).
$frameworkUrl = "https://github.com/wheels-dev/wheels/releases/download/v${moduleVersion}/wheels-core-${moduleVersion}.zip"
$frameworkPath = Join-Path $toolsDir "wheels-core.zip"
Invoke-WebRequest -Uri $frameworkUrl -OutFile $frameworkPath -UseBasicParsing
$frameworkExpectedHash = "2B7BE909ED949F7ECF3C9471200448B36C7B0084649DA3C03248F609EE30FE93"
$frameworkActualHash = (Get-FileHash -Path $frameworkPath -Algorithm SHA256).Hash
if ($frameworkActualHash -ne $frameworkExpectedHash) {
    Remove-Item $frameworkPath -Force
    throw "wheels-core-${moduleVersion}.zip SHA256 mismatch: expected $frameworkExpectedHash, got $frameworkActualHash"
}
$frameworkDir = Join-Path $toolsDir "framework"
if (Test-Path $frameworkDir) { Remove-Item $frameworkDir -Recurse -Force }
Expand-Archive -Path $frameworkPath -DestinationPath $frameworkDir -Force
Remove-Item $frameworkPath -Force

# Download SQLite JDBC driver. Lucee 7's BundleProvider crashes when resolving
# sqlite-jdbc via the bundleName hint, so wheels >=4.0 generates app.cfm
# without the hint and relies on the JAR being on the classpath. The wrapper
# drops it into %USERPROFILE%\.wheels\express\<lucee>\lib\ext\ on every run.
$libDir = Join-Path $toolsDir "lib"
if (-not (Test-Path $libDir)) { New-Item -ItemType Directory -Path $libDir | Out-Null }
$sqliteJdbcUrl = "https://repo1.maven.org/maven2/org/xerial/sqlite-jdbc/${sqliteJdbcVersion}/sqlite-jdbc-${sqliteJdbcVersion}.jar"
$sqliteJdbcPath = Join-Path $libDir "sqlite-jdbc-${sqliteJdbcVersion}.jar"
Invoke-WebRequest -Uri $sqliteJdbcUrl -OutFile $sqliteJdbcPath -UseBasicParsing
$expectedHash = "5C8609D2CA341DEB8C6F71778974B5BA4995C7D32D7C7C89D9392A3E72C39291"
$actualHash = (Get-FileHash -Path $sqliteJdbcPath -Algorithm SHA256).Hash
if ($actualHash -ne $expectedHash) {
    Remove-Item $sqliteJdbcPath -Force
    throw "sqlite-jdbc-${sqliteJdbcVersion}.jar SHA256 mismatch: expected $expectedHash, got $actualHash"
}

Write-Host "Wheels CLI installed successfully!" -ForegroundColor Green
Write-Host "Run 'wheels --version' to verify." -ForegroundColor Cyan



















































































































