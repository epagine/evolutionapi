#Requires -Version 5.1
<#
.SYNOPSIS
    Prepara o ambiente Evolution API no Windows (Laragon/Docker Desktop).
#>

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Set-Location $Root

function New-RandomHex {
    param([int]$Length = 32)
    $bytes = New-Object byte[] ($Length / 2)
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    return ([BitConverter]::ToString($bytes) -replace '-', '').ToLower()
}

Write-Host "=== Evolution API - Setup ===" -ForegroundColor Cyan

# .env (pode ser criado antes do Docker estar instalado)
if (-not (Test-Path ".env")) {
    if (-not (Test-Path ".env.example")) {
        Write-Error "Arquivo .env.example nao encontrado."
    }

    $apiKey = New-RandomHex 32
    $dbPass = New-RandomHex 24

    Copy-Item ".env.example" ".env"
    (Get-Content ".env" -Raw) `
        -replace 'ALTERE_ESTA_API_KEY', $apiKey `
        -replace 'ALTERE_ESTA_SENHA_FORTE', $dbPass |
        Set-Content ".env" -NoNewline

    Write-Host ""
    Write-Host ".env criado com chaves geradas automaticamente." -ForegroundColor Green
    Write-Host "  AUTHENTICATION_API_KEY: $apiKey" -ForegroundColor DarkGray
    Write-Host "  POSTGRES_PASSWORD:      $dbPass" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Guarde a API KEY em local seguro. Ela nao sera exibida novamente." -ForegroundColor Yellow
} else {
    Write-Host ".env ja existe - mantido." -ForegroundColor DarkGray
}

# Docker
$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    Write-Host ""
    Write-Host "Docker nao encontrado." -ForegroundColor Yellow
    Write-Host "Instale o Docker Desktop para Windows:" -ForegroundColor Yellow
    Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Apos instalar, reinicie o PC, abra o Docker Desktop e execute:" -ForegroundColor Yellow
    Write-Host "  .\scripts\start.ps1" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Docker: $(docker --version)" -ForegroundColor Green
Write-Host "Compose: $(docker compose version)" -ForegroundColor Green

Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "  Desenvolvimento:  docker compose up -d" -ForegroundColor White
Write-Host "  Producao:         docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d" -ForegroundColor White
Write-Host ""
Write-Host "  API:      http://localhost:8080" -ForegroundColor White
Write-Host "  Manager:  http://localhost:3000" -ForegroundColor White
Write-Host "  Logs:     docker compose logs -f api" -ForegroundColor White
