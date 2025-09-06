# Wheels Chocolatey Package

This package provides the `wheels` command-line tool for Windows, which serves as a convenient wrapper for the Wheels CommandBox CLI.

## What it does

The `wheels` command allows you to run Wheels CLI commands directly from your command prompt or PowerShell without having to prefix them with `box`. 

Instead of typing:
```cmd
box wheels generate model User
```

You can simply type:
```cmd
wheels generate model User
```

## Installation

Install using Chocolatey:
```cmd
choco install wheels
```

### Prerequisites

This package depends on CommandBox, which will be automatically installed if you don't already have it:
```cmd
choco install commandbox
```

## Usage

Once installed, you can use the `wheels` command from any Command Prompt or PowerShell session:

```cmd
# Generate a new model
wheels generate model User

# Run migrations
wheels migrate up

# Start a development server
wheels server start

# Get help
wheels --help
```

The package installs both:
- `wheels.bat` - for Command Prompt
- `wheels.ps1` - for PowerShell

All arguments are passed through to the underlying `box wheels` command.

## Building the Package

If you want to build this package locally:

1. Install Chocolatey and the `choco` command
2. Clone this repository
3. Run the build command:
   ```cmd
   choco pack
   ```
4. Install the local package:
   ```cmd
   choco install wheels -s .
   ```

## Package Structure

```
chocolatey-wheels/
├── wheels.nuspec                    # Package specification
├── tools/
│   ├── chocolateyinstall.ps1      # Installation script
│   └── chocolateyuninstall.ps1    # Uninstall script
├── README.md
└── LICENSE
```

## Verification

To verify the installation worked correctly:

```cmd
# Check that the command is available
where wheels

# Test the command (will show Wheels CLI help)
wheels --help
```

## Troubleshooting

If you encounter issues:

1. **Command not found**: 
   - Restart your command prompt/PowerShell
   - Check that Chocolatey's tools directory is in your PATH
   
2. **CommandBox not found**: 
   - Ensure CommandBox is installed from https://www.ortussolutions.com/products/commandbox
   - Restart your command prompt after installation
   
3. **Permission issues**: 
   - Run as Administrator: `choco install wheels --force`

## Updating

To update to the latest version:
```cmd
choco upgrade wheels
```

## Uninstalling

```cmd
choco uninstall wheels
```

## Publishing to Chocolatey Community Repository

To submit this package to the official Chocolatey repository:

1. Create an account at https://chocolatey.org/
2. Generate an API key
3. Run: `choco push wheels.1.0.0.nupkg --source https://push.chocolatey.org/`

## Contributing

Issues and pull requests are welcome at [https://github.com/wheels-dev/chocolatey-wheels](https://github.com/wheels-dev/chocolatey-wheels).

## License

This Chocolatey package is available as open source under the terms of the MIT License.