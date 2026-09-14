@echo off
cd /d "%~dp0"
title Nepal Flood Volume Demo V3 Corrected
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve_v3.ps1"
