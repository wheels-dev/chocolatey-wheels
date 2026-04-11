# Chocolatey Wheels

Chocolatey package for the [Wheels](https://wheels.dev) CLI — the command-line tool for the Wheels MVC framework.

## Install

```powershell
choco install wheels
```

## Usage

```powershell
wheels new myapp            # scaffold a new project
wheels server start         # start development server
wheels test                 # run test suite
wheels generate model User  # generate a model
wheels --version            # show version info
```

## Requirements

- Java 21 (installed automatically as a dependency)
- Windows

## Update

```powershell
choco upgrade wheels
```

## Uninstall

```powershell
choco uninstall wheels
```

## How It Works

This package installs [LuCLI](https://github.com/cybersonic/LuCLI) (the Lucee CLI) as the `wheels` command, along with the Wheels CLI module. LuCLI's binary-name detection automatically activates Wheels branding and routes commands to the Wheels module.
