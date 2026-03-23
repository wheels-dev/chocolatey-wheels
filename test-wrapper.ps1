# Test script to verify the wheels wrapper logic without actually installing

Write-Host "Testing Wheels CLI Wrapper Logic (LuCLI)" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Test 1: Check LuCLI availability
Write-Host "Test 1: LuCLI availability" -ForegroundColor Yellow
Write-Host "--------------------------" -ForegroundColor Yellow

$lucliInstalled = $false
try {
    $lucliPath = Get-Command lucli -ErrorAction SilentlyContinue
    if ($lucliPath) {
        $lucliInstalled = $true
    }
} catch {}

if ($lucliInstalled) {
    Write-Host "[PASS] LuCLI found at: $($lucliPath.Source)" -ForegroundColor Green
} else {
    Write-Host "[INFO] LuCLI not found (install via: choco install lucli)" -ForegroundColor Yellow
}
Write-Host ""

# Test 2: Verify wrapper script exists and has correct content
Write-Host "Test 2: Verify wrapper script" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow

$wrapperPath = Join-Path $PSScriptRoot "tools\wheels.cmd"
if (Test-Path $wrapperPath) {
    Write-Host "[PASS] wheels.cmd exists" -ForegroundColor Green

    $content = Get-Content $wrapperPath -Raw

    $checks = @(
        @{Name="LuCLI check"; Pattern="where lucli"},
        @{Name="LuCLI wheels passthrough"; Pattern="lucli wheels %*"},
        @{Name="Error exit code"; Pattern="exit /b %ERRORLEVEL%"}
    )

    foreach ($check in $checks) {
        if ($content -like "*$($check.Pattern)*") {
            Write-Host "       [PASS] $($check.Name)" -ForegroundColor Green
        } else {
            Write-Host "       [FAIL] $($check.Name)" -ForegroundColor Red
        }
    }

    # Verify old CommandBox patterns are gone
    $oldPatterns = @(
        @{Name="No CommandBox reference"; Pattern="box wheels"; ShouldExist=$false},
        @{Name="No argument conversion"; Pattern="converted_args"; ShouldExist=$false},
        @{Name="No delayed expansion"; Pattern="enabledelayedexpansion"; ShouldExist=$false}
    )

    foreach ($check in $oldPatterns) {
        $found = $content -like "*$($check.Pattern)*"
        if ($found -eq $check.ShouldExist) {
            Write-Host "       [PASS] $($check.Name)" -ForegroundColor Green
        } else {
            Write-Host "       [FAIL] $($check.Name)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "[FAIL] wheels.cmd not found" -ForegroundColor Red
}
Write-Host ""

# Test 3: Verify simplification
Write-Host "Test 3: Wrapper simplification" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Yellow

if (Test-Path $wrapperPath) {
    $lineCount = (Get-Content $wrapperPath).Count
    Write-Host "       wheels.cmd is $lineCount lines (was 142 with CommandBox)" -ForegroundColor Cyan
    if ($lineCount -lt 20) {
        Write-Host "[PASS] Wrapper is properly simplified" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Wrapper may still have unnecessary complexity" -ForegroundColor Yellow
    }
}
Write-Host ""

# Test 4: Installation script features
Write-Host "Test 4: Installation script features" -ForegroundColor Yellow
Write-Host "------------------------------------" -ForegroundColor Yellow

$installScript = Join-Path $PSScriptRoot "tools\chocolateyinstall.ps1"
if (Test-Path $installScript) {
    $installContent = Get-Content $installScript -Raw

    $features = @(
        @{Name="LuCLI detection"; Pattern="Get-Command.*lucli"},
        @{Name="Module installation"; Pattern="lucli modules install wheels"},
        @{Name="Module URL"; Pattern="wheels-dev/wheels"},
        @{Name="Create bat wrapper"; Pattern="wheels.bat"},
        @{Name="Create ps1 wrapper"; Pattern="wheels.ps1"}
    )

    foreach ($feature in $features) {
        if ($installContent -match $feature.Pattern) {
            Write-Host "[PASS] $($feature.Name)" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] $($feature.Name)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "[FAIL] chocolateyinstall.ps1 not found" -ForegroundColor Red
}
Write-Host ""

# Test 5: Uninstall script features
Write-Host "Test 5: Uninstall script features" -ForegroundColor Yellow
Write-Host "----------------------------------" -ForegroundColor Yellow

$uninstallScript = Join-Path $PSScriptRoot "tools\chocolateyuninstall.ps1"
if (Test-Path $uninstallScript) {
    $uninstallContent = Get-Content $uninstallScript -Raw

    $features = @(
        @{Name="Remove bat wrapper"; Pattern="wheels.bat"},
        @{Name="Remove ps1 wrapper"; Pattern="wheels.ps1"},
        @{Name="Module uninstall"; Pattern="lucli modules uninstall wheels"}
    )

    foreach ($feature in $features) {
        if ($uninstallContent -match $feature.Pattern) {
            Write-Host "[PASS] $($feature.Name)" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] $($feature.Name)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "[FAIL] chocolateyuninstall.ps1 not found" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "Test Summary" -ForegroundColor Green
Write-Host "============" -ForegroundColor Green
Write-Host "The wheels package has been updated to use LuCLI." -ForegroundColor Green
Write-Host ""
Write-Host "Key changes from v1.x (CommandBox):" -ForegroundColor Yellow
Write-Host "- Dependency: commandbox -> lucli" -ForegroundColor Cyan
Write-Host "- Wrapper: 142-line batch with arg conversion -> simple passthrough" -ForegroundColor Cyan
Write-Host "- Module: auto-installed via 'lucli modules install wheels'" -ForegroundColor Cyan
Write-Host "- Native CLI conventions (--flag, --param=value) handled by LuCLI" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: Full installation requires LuCLI to be available on Chocolatey." -ForegroundColor Yellow
