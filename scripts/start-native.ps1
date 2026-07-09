#Requires -Version 5.1
<#
.SYNOPSIS
    Inicia Evolution API nativamente (Redis + API).
#>

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ApiDir = Join-Path $Root "api"

Set-Location $Root

function Find-LaragonBin {
    param([string]$Pattern)
    $base = "C:\laragon\bin"
    if (-not (Test-Path $base)) { return $null }
    Get-ChildItem -Path $base -Recurse -Filter $Pattern -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
}

if (-not (Test-Path $ApiDir)) {
    Write-Host "API nao instalada. Execute primeiro: .\scripts\setup-native.ps1" -ForegroundColor Yellow
    exit 1
}

# MySQL
$mysql = Find-LaragonBin "mysql.exe"
if ($mysql) {
    try {
        & $mysql -uroot -e "SELECT 1" 2>$null | Out-Null
        Write-Host "MySQL: OK" -ForegroundColor Green
    } catch {
        Write-Host "MySQL nao esta rodando. Inicie pelo Laragon (Start All)." -ForegroundColor Red
        exit 1
    }
}

# Redis
$redisCli = Find-LaragonBin "redis-cli.exe"
$redisServer = Find-LaragonBin "redis-server.exe"
$redisRunning = $false

if ($redisCli) {
    try {
        $pong = & $redisCli ping 2>$null
        if ($pong -eq "PONG") { $redisRunning = $true }
    } catch { }
}

if (-not $redisRunning -and $redisServer) {
    Write-Host "Iniciando Redis..." -ForegroundColor Cyan
    $redisDir = Split-Path $redisServer -Parent
    Start-Process -FilePath $redisServer -WorkingDirectory $redisDir -WindowStyle Hidden
    Start-Sleep -Seconds 2
    if ($redisCli) {
        $pong = & $redisCli ping 2>$null
        if ($pong -eq "PONG") { $redisRunning = $true }
    }
}

if (-not $redisRunning) {
    Write-Host "Redis nao esta rodando. Inicie pelo Laragon ou instale Redis." -ForegroundColor Red
    exit 1
}
Write-Host "Redis: OK" -ForegroundColor Green

# Sincronizar .env
Copy-Item ".env" (Join-Path $ApiDir ".env") -Force

# Evitar processo duplicado na porta 8080
$portInUse = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "Porta 8080 em uso. Execute .\scripts\restart-native.ps1 para reiniciar limpo." -ForegroundColor Yellow
    exit 1
}

# Iniciar API
Write-Host ""
Write-Host "Iniciando Evolution API na porta 8080..." -ForegroundColor Cyan
Write-Host "Pressione Ctrl+C para parar." -ForegroundColor DarkGray
Write-Host ""

Set-Location $ApiDir
cmd /c "npm run start:prod"
