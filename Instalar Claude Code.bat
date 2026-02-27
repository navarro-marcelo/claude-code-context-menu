@echo off
:: Instalador Claude Code - Menu de Contexto do Windows Explorer
:: Executa o script PowerShell como Administrador

echo.
echo ============================================
echo    Claude Code - Instalador
echo ============================================
echo.
echo Este instalador vai adicionar "Claude Code" ao menu
echo de contexto do botao direito em pastas do Explorer.
echo.
echo Uma janela de permissao de administrador sera exibida.
echo.
pause

powershell.exe -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0install.ps1\"' -Verb RunAs"
