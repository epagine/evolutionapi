#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ApiDir = Join-Path $Root "api"
$Target = Join-Path $ApiDir "src\api\services\channel.service.ts"
$Patch = Join-Path $Root "patches\mysql-fetch-chats.patch"

if (-not (Test-Path $Target)) {
    Write-Host "Arquivo nao encontrado: $Target" -ForegroundColor Yellow
    exit 0
}

$content = Get-Content $Target -Raw
if ($content -match 'fetchChatsMysql') {
    Write-Host "Patch MySQL Chat ja aplicado." -ForegroundColor DarkGray
    exit 0
}

Set-Location $ApiDir
git apply --ignore-whitespace $Patch
if ($LASTEXITCODE -ne 0) {
  Write-Host "git apply falhou, tentando patch manual..." -ForegroundColor Yellow
  Set-Location $Root
  exit 1
}

Write-Host "Patch MySQL Chat aplicado com sucesso." -ForegroundColor Green
