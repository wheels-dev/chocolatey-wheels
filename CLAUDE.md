# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Chocolatey package that provides a Windows CLI wrapper for the Wheels MVC framework CommandBox tools. The package creates a `wheels` command that simplifies CommandBox usage by eliminating the need to prefix commands with `box wheels`.

## Package Structure

- **wheels.nuspec**: Package specification with metadata, dependencies (CommandBox), and version info
- **tools/chocolateyinstall.ps1**: Installation script that creates wrapper scripts dynamically
- **tools/wheels.cmd**: Windows batch wrapper that handles argument conversion and CommandBox integration
- **build.ps1**: Build script for packaging with version management
- **test-local.ps1**: Local testing script for package installation
- **test-wrapper.ps1**: Logic verification script for wrapper functionality

## Key Commands

### Package Building
```powershell
# Build package (uses existing version in nuspec)
choco pack

# Build with specific version
.\build.ps1 -Version "1.0.6"

# Build and push to Chocolatey (requires API key)
.\build.ps1 -Version "1.0.6" -Push -ApiKey YOUR_API_KEY
```

### Local Testing
```powershell
# Test local installation
.\test-local.ps1

# Uninstall test installation
.\test-local.ps1 -Uninstall

# Test wrapper logic without installation
.\test-wrapper.ps1
```

## Architecture Details

### Wrapper Logic (tools/wheels.cmd)
- Checks for CommandBox availability at runtime
- Auto-installs Wheels CLI tools if not present (`box install wheels-cli`)
- Converts standard CLI arguments to CommandBox parameter format:
  - `--parameter=value` → `parameter=value`
  - `--flag` → `flag=true`
  - `--noFlag` → `flag=false`
- Handles special cases for `--help`, `--version`

### Installation Process
1. Creates `wheels.bat` and `wheels.ps1` wrapper scripts in tools directory
2. Chocolatey automatically adds tools directory to PATH
3. Wrapper scripts check CommandBox dependency and install Wheels CLI on first use

### Version Management
The build script automatically updates the version in `wheels.nuspec` when using the `-Version` parameter.

## Dependencies

- **CommandBox**: Required dependency (version 5.0.0+) specified in nuspec
- **Wheels CLI**: Auto-installed by wrapper on first use via `box install wheels-cli`

## Testing Approach

- `test-local.ps1`: Full end-to-end testing with actual Chocolatey installation
- `test-wrapper.ps1`: Logic verification without system changes
- Manual testing: Install package and verify `wheels` command works

## Recent Fixes (v1.0.6)

**Chocolatey Automated Validation Issues Resolved:**
- ✅ **Choco commands in scripts**: Confirmed package scripts (chocolateyinstall.ps1, chocolateyuninstall.ps1) contain no choco commands (requirement satisfied)
- ✅ **IconUrl**: Added iconUrl element pointing to Wheels project logo
- ✅ **ProjectSourceUrl**: Already correctly points to software source code (wheels-dev/wheels)

**Package Quality Notes:**
- Package maintainer (wheels-dev) matches software author (Wheels Team) - standard for official packages
- ProjectUrl points to this package repository, ProjectSourceUrl points to main software repository (correct)

## Permissions Configuration

The repository includes Claude Code permissions in `.claude/settings.local.json` allowing:
- Directory operations
- Git operations (add/commit)  
- Chocolatey pack operations