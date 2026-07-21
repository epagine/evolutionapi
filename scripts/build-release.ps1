#Requires -Version 5.1
<#
.SYNOPSIS
    Gera pacote de producao para upload ao servidor (FTP/SFTP).
    Build local + arquivos prontos. node_modules e instalado NO SERVIDOR (Linux).
#>

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ApiDir = Join-Path $Root "api"
$ReleaseDir = Join-Path $Root "release\upload"
$EnvProduction = Join-Path $Root ".env.production"

Set-Location $Root

Write-Host "=== Build Release - Evolution API ===" -ForegroundColor Cyan

# Verificar .env.production
if (-not (Test-Path $EnvProduction)) {
    Write-Host ""
    Write-Host "Arquivo .env.production nao encontrado." -ForegroundColor Yellow
    if (Test-Path ".env.production.example") {
        Copy-Item ".env.production.example" $EnvProduction
        Write-Host "Criado .env.production a partir do exemplo." -ForegroundColor Yellow
        Write-Host "Edite .env.production com credenciais de producao e execute novamente." -ForegroundColor Yellow
        exit 1
    }
    Write-Error ".env.production.example nao encontrado."
}

# Garantir api/ compilada
if (-not (Test-Path (Join-Path $ApiDir "dist\main.js"))) {
    Write-Host "API nao compilada. Executando setup-native..." -ForegroundColor Yellow
    & "$Root\scripts\setup-native.ps1"
}

if (-not (Test-Path (Join-Path $ApiDir "dist\main.js"))) {
    Write-Error "Build falhou - dist/main.js nao encontrado."
}

# Recompilar com patch MySQL
Write-Host "Recompilando API..." -ForegroundColor Cyan
Copy-Item $EnvProduction (Join-Path $ApiDir ".env") -Force
& "$Root\scripts\apply-mysql-chat-patch.ps1" 2>$null
Set-Location $ApiDir
cmd /c "npx tsup 2>&1" | Out-Null
Set-Location $Root
& "$Root\scripts\fix-manager-assets.ps1" | Out-Null

# Limpar release anterior
if (Test-Path $ReleaseDir) {
    Remove-Item -Recurse -Force $ReleaseDir
}
New-Item -ItemType Directory -Force -Path $ReleaseDir | Out-Null

Write-Host "Montando pacote de upload..." -ForegroundColor Cyan

# Arquivos necessarios em runtime (SEM node_modules)
$copyItems = @(
    "dist",
    "manager",
    "public",
    "prisma",
    "package.json",
    "package-lock.json",
    "runWithProvider.js"
)

foreach ($item in $copyItems) {
    $src = Join-Path $ApiDir $item
    if (Test-Path $src) {
        Copy-Item -Recurse -Force $src (Join-Path $ReleaseDir $item)
    }
}

# .env de producao
Copy-Item $EnvProduction (Join-Path $ReleaseDir ".env") -Force

# Pasta instances (sessoes WhatsApp)
New-Item -ItemType Directory -Force -Path (Join-Path $ReleaseDir "instances") | Out-Null

# Scripts do servidor
Copy-Item (Join-Path $Root "release\templates\install-no-servidor.sh") (Join-Path $ReleaseDir "install-no-servidor.sh") -Force
Copy-Item (Join-Path $Root "release\templates\install.php") (Join-Path $ReleaseDir "install.php") -Force
Copy-Item (Join-Path $Root "database\schema.sql") (Join-Path $ReleaseDir "schema.sql") -Force

# LEIA-ME
@'
# Pacote de producao - Evolution API v2.3.7

## SEM SSH (recomendado no cPanel)

1. Importe schema.sql no phpMyAdmin (ou deixe o instalador fazer)
2. Envie TODO o conteudo desta pasta via FTP (ex: public_html/evolution/)
3. Abra no navegador: https://SEU-DOMINIO/install.php
4. Preencha MySQL / URL / API Key e clique Instalar
5. No cPanel: Setup Node.js App
   - Application root: pasta do upload
   - Startup file: dist/main.js
   - Run NPM Install + Start
6. Apague install.php

Guia: docs/DEPLOY-SEM-SSH.md (no repositorio)

## COM SSH (alternativa)

  chmod +x install-no-servidor.sh
  bash install-no-servidor.sh

## IMPORTANTE
- NAO copie node_modules do Windows
- Redis e MySQL devem estar ativos no servidor
- SERVER_URL deve ser https://seu-dominio.com

## URLs
- API:     https://evolution.epage.app.br
- Manager: https://evolution.epage.app.br/manager
- Install: https://evolution.epage.app.br/install.php
'@ | Set-Content (Join-Path $ReleaseDir "LEIA-ME.txt") -Encoding UTF8

# Zip opcional
$zipPath = Join-Path $Root "release\evolution-api-upload.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path "$ReleaseDir\*" -DestinationPath $zipPath -CompressionLevel Optimal

$sizeMb = [math]::Round((Get-ChildItem $ReleaseDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 1)

Write-Host ""
Write-Host "=== Pacote pronto ===" -ForegroundColor Green
Write-Host ""
Write-Host "  Pasta:  release\upload\" -ForegroundColor White
Write-Host "  Zip:    release\evolution-api-upload.zip" -ForegroundColor White
Write-Host "  Tamanho: ~${sizeMb} MB (sem node_modules)" -ForegroundColor White
Write-Host ""
Write-Host "Proximos passos (SEM SSH):" -ForegroundColor Cyan
Write-Host "  1. Envie release\upload\ via FTP" -ForegroundColor White
Write-Host "  2. Abra https://seu-dominio/install.php" -ForegroundColor White
Write-Host "  3. No cPanel: Setup Node.js App -> Startup: dist/main.js" -ForegroundColor White
Write-Host "  4. Run NPM Install + Start" -ForegroundColor White
Write-Host ""
Write-Host "Guia: docs\DEPLOY-SEM-SSH.md" -ForegroundColor DarkGray
