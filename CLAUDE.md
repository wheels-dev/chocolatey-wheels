# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Chocolatey package that provides a Windows CLI wrapper for the Wheels MVC framework, powered by LuCLI. The package creates a `wheels` command that delegates to `lucli wheels`.

## Package Structure

- **wheels.nuspec**: Package specification with metadata, dependencies (LuCLI), and version info
- **tools/chocolateyinstall.ps1**: Installation script — installs Wheels LuCLI module, creates wrapper scripts
- **tools/chocolateyuninstall.ps1**: Uninstall script — removes module and wrapper scripts
- **tools/wheels.cmd**: Windows batch wrapper that passes arguments to `lucli wheels`
- **build.ps1**: Build script for packaging with version management
- **test-local.ps1**: Local testing script for package installation
- **test-wrapper.ps1**: Logic verification script for wrapper functionality

## Key Commands

### Package Building
```powershell
# Build package (uses existing version in nuspec)
choco pack

# Build with specific version
.\build.ps1 -Version "2.0.0"

# Build and push to Chocolatey (requires API key)
.\build.ps1 -Version "2.0.0" -Push -ApiKey YOUR_API_KEY
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
- Checks for LuCLI availability at runtime
- Passes all arguments directly to `lucli wheels` (no conversion needed)
- LuCLI handles standard CLI conventions natively

### Installation Process
1. Verifies LuCLI dependency is available
2. Installs Wheels module via `lucli modules install wheels`
3. Creates `wheels.bat` and `wheels.ps1` wrapper scripts in tools directory
4. Chocolatey automatically adds tools directory to PATH

### Version Management
The build script automatically updates the version in `wheels.nuspec` when using the `-Version` parameter.

## Dependencies

- **LuCLI**: Required dependency specified in nuspec
- **Wheels module**: Installed from wheels-dev/wheels monorepo archive during package install

## Testing Approach

- `test-local.ps1`: Full end-to-end testing with actual Chocolatey installation
- `test-wrapper.ps1`: Logic verification without system changes
- Manual testing: Install package and verify `wheels` command works

## Permissions Configuration

The repository includes Claude Code permissions in `.claude/settings.local.json` allowing:
- Directory operations
- Git operations (add/commit)
- Chocolatey pack operations
