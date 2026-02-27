@echo off
:: Desinstalador Claude Code - Menu de Contexto do Windows Explorer

echo.
echo ============================================
echo    Claude Code - Desinstalador
echo ============================================
echo.
echo Isso vai remover "Claude Code" do menu de contexto.
echo.
pause

powershell.exe -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0uninstall.ps1\"' -Verb RunAs"
