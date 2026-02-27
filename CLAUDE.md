# Claude Code Context Menu - Architecture & Solution Details

## Overview

This project adds a **"Claude Code"** option to the Windows Explorer right-click context menu on folders. When clicked, it presents a GUI form with launch options and opens a terminal running Claude Code in the selected directory.

## Architecture

```
claude-code-context-menu/
├── ClaudeCodeInstaller/          # C# WinForms installer project (.NET 10)
│   ├── Program.cs                # Main installer GUI (install/uninstall logic)
│   ├── ClaudeCodeInstaller.csproj
│   ├── app.manifest              # UAC elevation manifest (requireAdministrator)
│   └── Resources/
│       └── claude-code-launcher.ps1  # Embedded resource (extracted on install)
├── dist/
│   └── ClaudeCodeInstaller.exe   # Published single-file executable
├── claude-code-launcher.ps1      # WPF GUI launcher script (standalone copy)
├── install.ps1                   # PowerShell installer (alternative to .exe)
├── uninstall.ps1                 # PowerShell uninstaller (alternative to .exe)
├── Instalar Claude Code.bat      # Batch wrapper for PowerShell installer
├── Desinstalar Claude Code.bat   # Batch wrapper for PowerShell uninstaller
├── ClaudeCodeInstaller.exe       # Ready-to-distribute installer
└── README.md                     # User-facing documentation
```

## How It Works

### 1. Installation Flow

The installer (either `.exe` or `.ps1`) performs three operations:

1. **Creates install directory**: `C:\Program Files\ClaudeCodeLauncher\`
2. **Extracts the launcher script**: `claude-code-launcher.ps1` is written to the install directory
3. **Registers Windows Registry entries** for the context menu:
   - `HKLM\SOFTWARE\Classes\Directory\shell\ClaudeCode` — right-click on a folder
   - `HKLM\SOFTWARE\Classes\Directory\Background\shell\ClaudeCode` — right-click inside a folder (background)

Each registry key contains:
- `(Default)` = "Claude Code" (display text)
- `Position` = "Top" (appears at top of context menu)
- `command\(Default)` = PowerShell command to launch the GUI

### 2. Launcher Flow (claude-code-launcher.ps1)

When the user right-clicks a folder and selects "Claude Code":

1. Windows Explorer passes the folder path via `%V` to the PowerShell launcher
2. The launcher creates a **WPF window** with:
   - **Checkbox: "Modo Administrador"** — opens terminal with `RunAs` verb (UAC elevation)
   - **Checkbox: "Dangerously Skip Permissions"** — appends `--dangerously-skip-permissions` flag
3. On "Iniciar" click:
   - Builds the command: `cd /d "<folder>" && claude [--dangerously-skip-permissions]`
   - Launches `cmd.exe /k` with the command (keeps terminal open)
   - If admin mode is checked, uses `Start-Process -Verb RunAs`

### 3. The .exe Installer (C# WinForms)

The `.exe` is a self-contained Windows Forms application that:
- Requires administrator elevation via UAC manifest (`app.manifest`)
- Embeds `claude-code-launcher.ps1` as an assembly resource
- Extracts the script to `C:\Program Files\ClaudeCodeLauncher\` on install
- Writes/removes registry keys for install/uninstall
- Detects current installation state on startup
- Published as a **single-file executable** (~180KB, framework-dependent on .NET 10)

## Key Technical Decisions

- **WPF for launcher GUI**: Chosen over WinForms because PowerShell has native WPF support via `PresentationFramework`, allowing a modern-looking dark-themed UI without external dependencies.
- **cmd.exe /k for terminal**: Keeps the terminal window open after Claude Code exits, so users can see output. Using `/k` instead of `/c` prevents the window from closing.
- **Registry-based context menu**: Uses `HKLM` (machine-wide) instead of `HKCU` (per-user) so the context menu appears for all users on the machine. Requires admin rights.
- **Two registry paths**: `Directory\shell` handles right-clicking ON a folder; `Directory\Background\shell` handles right-clicking INSIDE a folder (on the background).
- **PowerShell ExecutionPolicy Bypass**: The registry command uses `-ExecutionPolicy Bypass` so the launcher works regardless of the system's execution policy.
- **-WindowStyle Hidden**: Hides the PowerShell host window; only the WPF form is visible.

## Prerequisites

- **Windows 10 or 11**
- **Claude Code CLI** installed and available in PATH (`claude` command)
- **PowerShell 5.1+** (included in Windows)
- **.NET 10 Runtime** (for the .exe installer only; the .bat/.ps1 alternative has no .NET dependency)

## Building

```bash
cd ClaudeCodeInstaller
dotnet publish -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true -o "../dist"
cp ../dist/ClaudeCodeInstaller.exe ../
```

To build a fully self-contained exe (no .NET runtime required, ~60MB):
```bash
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:PublishTrimmed=true -o "../dist-selfcontained"
```

## Modifying

- **To change the context menu label**: Edit the `"Claude Code"` string in `Program.cs` (for .exe) or `install.ps1` (for script installer)
- **To add more launch options**: Add checkboxes in `claude-code-launcher.ps1` (WPF XAML section) and handle them in the `btnLaunch.Add_Click` handler
- **To change the install directory**: Update `InstallDir` constant in `Program.cs` or `$installDir` in `install.ps1`
