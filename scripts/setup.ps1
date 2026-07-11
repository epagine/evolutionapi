#Requires -Version 5.1
<#
.SYNOPSIS
    Prepara o ambiente Evolution API no Windows de forma nativa, sem Docker.
#>

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Set-Location $Root

Write-Host "=== Evolution API - Setup Nativo ===" -ForegroundColor Cyan
Write-Host "Este script usa Laragon + MySQL + Redis + Node.js, sem Docker." -ForegroundColor DarkGray

& "$Root\scripts\setup-native.ps1"
