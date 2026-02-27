# Claude Code Context Menu for Windows Explorer

Adds a **"Claude Code"** option to the Windows Explorer right-click menu on folders. Launch Claude Code directly from any folder with optional admin mode and permission flags.

![Windows 10/11](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- Right-click any folder → **"Claude Code"** at the top of the context menu
- GUI launcher with options:
  - **Modo Administrador** — opens elevated terminal
  - **Dangerously Skip Permissions** — runs with `--dangerously-skip-permissions`
  - **Terminal selector** — pick CMD, Windows PowerShell, PowerShell 7, Windows Terminal, or Git Bash (only shows what's installed on your machine)
- Works on folder items AND inside folders (background click)
- One-click installer (.exe) with install/uninstall GUI
- Alternative PowerShell scripts for environments without .NET

## Quick Install

### Option 1: EXE Installer (Recommended)

1. Download `ClaudeCodeInstaller.exe` from [Releases](../../releases)
2. Double-click to run (accepts UAC prompt)
3. Click **"Instalar"**
4. Done! Right-click any folder to see "Claude Code"

> Requires .NET 10 Runtime. [Download here](https://dotnet.microsoft.com/download/dotnet/10.0)

### Option 2: PowerShell Scripts (No .NET needed)

1. Download or clone this repo
2. Double-click `Instalar Claude Code.bat`
3. Accept the UAC prompt
4. Done!

## Uninstall

- **EXE**: Run `ClaudeCodeInstaller.exe` → click "Desinstalar"
- **Scripts**: Double-click `Desinstalar Claude Code.bat`

## Prerequisites

- **Windows 10 or 11**
- **[Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)** installed and in PATH
- **PowerShell 5.1+** (included in Windows)

## How It Works

1. The installer registers a context menu entry in the Windows Registry
2. When clicked, a PowerShell script shows a WPF form with launch options
3. Based on your selections, a terminal opens running `claude` in the chosen folder

See [CLAUDE.md](CLAUDE.md) for full technical details.

## Building from Source

```bash
cd ClaudeCodeInstaller
dotnet publish -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true -o "../dist"
```

## License

MIT
