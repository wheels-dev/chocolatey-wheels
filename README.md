# CFWheels Chocolatey Package

This package provides the `wheels` command-line tool for Windows, which serves as a convenient wrapper for the CFWheels CommandBox CLI.

## What it does

The `wheels` command allows you to run CFWheels CLI commands directly from your terminal without having to prefix them with `box`. 

Instead of typing:
```powershell
box wheels generate model User
```

You can simply type:
```powershell
wheels generate model User
```

## Installation

Install using Chocolatey:
```powershell
choco install wheels
```

### Prerequisites

This package depends on CommandBox, which will be automatically installed if you don't already have it:
```powershell
choco install commandbox
```

## Usage

Once installed, you can use the `wheels` command exactly like you would use `box wheels`:

```powershell
# Generate a new model
wheels generate model User

# Run migrations
wheels migrate up

# Start a development server
wheels server start

# Get help
wheels --help
```

All arguments are passed through to the underlying `box wheels` command.

## Verification

To verify the installation worked correctly:

```powershell
# Check that the command is available
where wheels

# Test the command (will show CFWheels CLI help)
wheels --help
```

## Troubleshooting

If you encounter issues:

1. **Command not found**: Make sure Chocolatey's bin directory is in your PATH
2. **CommandBox not found**: Ensure CommandBox is installed: `choco install commandbox`
3. **Permission issues**: Try reinstalling: `choco uninstall wheels && choco install wheels`

## Building from Source

To build the Chocolatey package from source:

```powershell
# Clone the repository
git clone https://github.com/wheels-dev/chocolatey-wheels.git
cd chocolatey-wheels

# Build the package
.\build.ps1

# Test locally
.\test-local.ps1

# Push to Chocolatey (requires API key)
.\build.ps1 -Push -ApiKey YOUR_API_KEY
```

## Updating

To update to the latest version:
```powershell
choco upgrade wheels
```

## Uninstalling

```powershell
choco uninstall wheels
```

Note: This will only remove the wheels wrapper. CommandBox will remain installed unless you explicitly uninstall it:
```powershell
choco uninstall commandbox
```

## Contributing

Issues and pull requests are welcome at [https://github.com/wheels-dev/chocolatey-wheels](https://github.com/wheels-dev/chocolatey-wheels).

## License

This Chocolatey package is available as open source under the terms of the MIT License.