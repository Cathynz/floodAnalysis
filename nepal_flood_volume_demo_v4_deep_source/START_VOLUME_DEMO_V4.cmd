@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0serve_v4.ps1"
