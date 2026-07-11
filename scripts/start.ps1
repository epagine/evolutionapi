#Requires -Version 5.1
param(
    [ValidateSet("dev", "prod")]
    [string]$Mode = "dev"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

Write-Host "=== Evolution API - Iniciar (nativo) ===" -ForegroundColor Cyan

if (-not (Test-Path ".env")) {
    & "$Root\scripts\setup.ps1"
}

if ($Mode -eq "prod") {
    Write-Host "Iniciando ambiente de PRODUCAO..." -ForegroundColor Yellow
    & "$Root\scripts\start-native.ps1"
} else {
    Write-Host "Iniciando ambiente de DESENVOLVIMENTO..." -ForegroundColor Green
    & "$Root\scripts\start-native.ps1"
}
