#Requires -Version 5.1
param(
    [ValidateSet("dev", "prod")]
    [string]$Mode = "dev"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker nao encontrado. Execute scripts\setup.ps1 apos instalar o Docker Desktop."
}

if (-not (Test-Path ".env")) {
    & "$Root\scripts\setup.ps1"
}

if ($Mode -eq "prod") {
    Write-Host "Subindo ambiente de PRODUCAO..." -ForegroundColor Yellow
    docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
} else {
    Write-Host "Subindo ambiente de DESENVOLVIMENTO..." -ForegroundColor Green
    docker compose up -d
}

Write-Host ""
docker compose ps
Write-Host ""
Write-Host "Aguarde ~1 minuto na primeira execucao (download de imagens + migrations)." -ForegroundColor Cyan
Write-Host "API:     http://localhost:8080" -ForegroundColor White
Write-Host "Manager: http://localhost:3000" -ForegroundColor White
