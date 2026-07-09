#Requires -Version 5.1
<#
.SYNOPSIS
    Instala Evolution API nativamente (sem Docker) usando Laragon.
#>

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ApiDir = Join-Path $Root "api"
$Tag = "2.3.7"

Set-Location $Root

function New-RandomHex {
    param([int]$Length = 32)
    $bytes = New-Object byte[] ($Length / 2)
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    return ([BitConverter]::ToString($bytes) -replace '-', '').ToLower()
}

function Find-LaragonBin {
    param([string]$Pattern)
    $base = "C:\laragon\bin"
    if (-not (Test-Path $base)) { return $null }
    Get-ChildItem -Path $base -Recurse -Filter $Pattern -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
}

Write-Host "=== Evolution API - Setup Nativo (sem Docker) ===" -ForegroundColor Cyan

# Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js nao encontrado. Instale via Laragon (Menu > Node.js) ou https://nodejs.org"
}
Write-Host "Node:  $(node --version)" -ForegroundColor Green
Write-Host "npm:   $(npm --version)" -ForegroundColor Green

# Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git nao encontrado. Instale via Laragon ou https://git-scm.com"
}

# MySQL
$mysql = Find-LaragonBin "mysql.exe"
if (-not $mysql) {
    Write-Error "MySQL do Laragon nao encontrado em C:\laragon\bin\mysql"
}
Write-Host "MySQL: $mysql" -ForegroundColor Green

try {
    & $mysql -uroot -e "SELECT 1" 2>$null | Out-Null
} catch {
    Write-Host ""
    Write-Host "MySQL nao esta rodando." -ForegroundColor Yellow
    Write-Host "Abra o Laragon e clique em 'Start All' (ou inicie apenas o MySQL)." -ForegroundColor Yellow
    exit 1
}

# .env
if (-not (Test-Path ".env")) {
    $apiKey = New-RandomHex 32
    Copy-Item ".env.native.example" ".env"
    (Get-Content ".env" -Raw) -replace 'ALTERE_ESTA_API_KEY', $apiKey | Set-Content ".env" -NoNewline
    Write-Host ".env criado (API KEY gerada)." -ForegroundColor Green
} else {
    Write-Host ".env existente - mantido." -ForegroundColor DarkGray
}

# Banco de dados
$dbName = "evolution"
& $mysql -uroot -e "CREATE DATABASE IF NOT EXISTS ``$dbName`` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>$null
Write-Host "Banco '$dbName' verificado/criado." -ForegroundColor Green

# Clone do repositorio
if (-not (Test-Path $ApiDir)) {
    Write-Host ""
    Write-Host "Clonando evolution-api v$Tag (pode demorar alguns minutos)..." -ForegroundColor Cyan
    git clone --depth 1 --branch $Tag https://github.com/evolution-foundation/evolution-api.git $ApiDir
} else {
    Write-Host "Pasta api/ ja existe - pulando clone." -ForegroundColor DarkGray
}

# Copiar .env para api/
Copy-Item ".env" (Join-Path $ApiDir ".env") -Force

# Patch MySQL para aba Chat do Manager
& "$Root\scripts\apply-mysql-chat-patch.ps1"

# Dependencias
Write-Host ""
Write-Host "Instalando dependencias npm (pode demorar)..." -ForegroundColor Cyan
Set-Location $ApiDir
cmd /c "npm install --legacy-peer-deps 2>&1"

# Prisma na versao compativel com o tag 2.3.7
cmd /c "npm install prisma@6.16.2 @prisma/client@6.16.2 --save-exact 2>&1"

# Migrations
Write-Host ""
Write-Host "Aplicando migrations do banco..." -ForegroundColor Cyan
cmd /c "npm run db:generate 2>&1"
if (Test-Path "prisma\migrations") { Remove-Item -Recurse -Force "prisma\migrations" }
cmd /c "xcopy /E /I /Y prisma\mysql-migrations prisma\migrations"
cmd /c "npx prisma migrate deploy --schema prisma\mysql-schema.prisma 2>&1"

# Build (tsup apenas - tsc falha com Node 24)
Write-Host ""
Write-Host "Compilando projeto..." -ForegroundColor Cyan
cmd /c "npx tsup 2>&1"

Set-Location $Root
& "$Root\scripts\fix-manager-assets.ps1"

Write-Host ""
Write-Host "=== Setup concluido ===" -ForegroundColor Green
Write-Host ""
Write-Host "Proximo passo:" -ForegroundColor Cyan
Write-Host "  1. No Laragon: inicie MySQL e Redis (Start All)" -ForegroundColor White
Write-Host "  2. Execute: .\scripts\start-native.ps1" -ForegroundColor White
Write-Host ""
Write-Host "  API:     http://localhost:8080" -ForegroundColor White
Write-Host "  Manager: http://localhost:8080/manager" -ForegroundColor White
