#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Instala o "Claude Code" no menu de contexto do Windows Explorer (botao direito em pastas).
.DESCRIPTION
    - Copia o launcher para C:\Program Files\ClaudeCodeLauncher
    - Cria entradas no registro para o menu de contexto de pastas
    - Funciona no Windows 10 e 11
#>

$ErrorActionPreference = "Stop"

$installDir = "C:\Program Files\ClaudeCodeLauncher"
$launcherScript = "claude-code-launcher.ps1"
$iconName = "claude-code.ico"
$sourceDir = $PSScriptRoot

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Claude Code - Context Menu Installer"     -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Create install directory
Write-Host "[1/3] Criando diretorio de instalacao..." -ForegroundColor Yellow
if (!(Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# 2. Copy files
Write-Host "[2/3] Copiando arquivos..." -ForegroundColor Yellow
Copy-Item -Path (Join-Path $sourceDir $launcherScript) -Destination $installDir -Force

# Copy icon if it exists
$iconSource = Join-Path $sourceDir $iconName
if (Test-Path $iconSource) {
    Copy-Item -Path $iconSource -Destination $installDir -Force
}

# 3. Register context menu entries
Write-Host "[3/3] Registrando menu de contexto..." -ForegroundColor Yellow

$launcherPath = Join-Path $installDir $launcherScript
$iconPath = Join-Path $installDir $iconName

# Command that the context menu will execute
# %V is the folder path passed by Explorer
$command = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcherPath`" -FolderPath `"%V`""

# --- Registry: Right-click on a folder ---
$regPathFolder = "HKLM:\SOFTWARE\Classes\Directory\shell\ClaudeCode"
$regPathFolderCmd = "$regPathFolder\command"

if (Test-Path $regPathFolder) { Remove-Item -Path $regPathFolder -Recurse -Force }
New-Item -Path $regPathFolder -Force | Out-Null
Set-ItemProperty -Path $regPathFolder -Name "(Default)" -Value "Claude Code"
Set-ItemProperty -Path $regPathFolder -Name "Position" -Value "Top"
if (Test-Path $iconPath) {
    Set-ItemProperty -Path $regPathFolder -Name "Icon" -Value $iconPath
}
New-Item -Path $regPathFolderCmd -Force | Out-Null
Set-ItemProperty -Path $regPathFolderCmd -Name "(Default)" -Value $command

# --- Registry: Right-click on folder background (inside a folder) ---
$regPathBg = "HKLM:\SOFTWARE\Classes\Directory\Background\shell\ClaudeCode"
$regPathBgCmd = "$regPathBg\command"

if (Test-Path $regPathBg) { Remove-Item -Path $regPathBg -Recurse -Force }
New-Item -Path $regPathBg -Force | Out-Null
Set-ItemProperty -Path $regPathBg -Name "(Default)" -Value "Claude Code"
Set-ItemProperty -Path $regPathBg -Name "Position" -Value "Top"
if (Test-Path $iconPath) {
    Set-ItemProperty -Path $regPathBg -Name "Icon" -Value $iconPath
}
New-Item -Path $regPathBgCmd -Force | Out-Null
Set-ItemProperty -Path $regPathBgCmd -Name "(Default)" -Value $command

Write-Host ""
Write-Host "Instalacao concluida com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "Agora voce pode clicar com o botao direito em qualquer pasta" -ForegroundColor White
Write-Host "e selecionar 'Claude Code' no menu de contexto." -ForegroundColor White
Write-Host ""
Write-Host "Para desinstalar, execute: uninstall.ps1" -ForegroundColor Gray
Write-Host ""
Read-Host "Pressione Enter para sair"
