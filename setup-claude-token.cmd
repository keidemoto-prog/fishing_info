@echo off
rem One-time helper (double-click). Messages are in setup-claude-token-msg.txt.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-claude-token.ps1"
pause
