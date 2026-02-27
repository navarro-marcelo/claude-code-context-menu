#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Remove o "Claude Code" do menu de contexto do Windows Explorer.
#>

$ErrorActionPreference = "Stop"

$installDir = "C:\Program Files\ClaudeCodeLauncher"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Claude Code - Context Menu Uninstaller"   -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Remove registry entries
Write-Host "[1/2] Removendo entradas do registro..." -ForegroundColor Yellow

$regPaths = @(
    "HKLM:\SOFTWARE\Classes\Directory\shell\ClaudeCode",
    "HKLM:\SOFTWARE\Classes\Directory\Background\shell\ClaudeCode"
)

foreach ($path in $regPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "  Removido: $path" -ForegroundColor Gray
    }
}

# 2. Remove installed files
Write-Host "[2/2] Removendo arquivos instalados..." -ForegroundColor Yellow
if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
    Write-Host "  Removido: $installDir" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Desinstalacao concluida com sucesso!" -ForegroundColor Green
Write-Host ""
Read-Host "Pressione Enter para sair"
