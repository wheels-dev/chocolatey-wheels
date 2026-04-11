# CLAUDE.md

## What This Is

Chocolatey package for the Wheels CLI. Installs LuCLI .bat launcher + Wheels module.

## Package Structure

- `wheels.nuspec` — package spec (version, dependencies, metadata)
- `tools/chocolateyinstall.ps1` — downloads LuCLI .bat and module zip
- `tools/chocolateyuninstall.ps1` — cleanup
- `tools/wheels.cmd` — wrapper that copies module to ~/.wheels/ on first run

## Version Constants

In `tools/chocolateyinstall.ps1`:
- `$lucliVersion` — LuCLI version to download
- `$moduleVersion` — Wheels module version to download

## Development Commands

```powershell
choco pack wheels.nuspec              # build .nupkg
choco install wheels --source .       # test install locally
```

## Auto-Update

`.github/workflows/auto-update.yml` polls cybersonic/LuCLI and wheels-dev/wheels releases daily.
