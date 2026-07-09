#Requires -Version 5.1
<#
.SYNOPSIS
    Corrige assets do Evolution Manager (logos/favicon 404).
#>

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ApiDir = Join-Path $Root "api"
$PublicEvo = Join-Path $ApiDir "public\files\evo"
$ManagerDist = Join-Path $ApiDir "manager\dist"

# Garantir assets locais
New-Item -ItemType Directory -Force -Path $PublicEvo, (Join-Path $ApiDir "public\assets\images") | Out-Null

$assets = @(
    "favicon.svg",
    "evolution-logo-white.svg",
    "evolution-logo.svg"
)
foreach ($file in $assets) {
    $src = Join-Path $Root "assets\manager\$file"
    $dst = Join-Path $PublicEvo $file
    if (Test-Path $src) {
        Copy-Item $src $dst -Force
    }
}

# PNG do manager (fallback de avatar)
$pngUrl = "https://raw.githubusercontent.com/evolution-foundation/evolution-manager-v2/main/public/assets/images/evolution-logo.png"
$pngDst = Join-Path $ApiDir "public\assets\images\evolution-logo.png"
if (-not (Test-Path $pngDst)) {
    try {
        Invoke-WebRequest -Uri $pngUrl -OutFile $pngDst -UseBasicParsing
    } catch {
        Write-Host "Aviso: nao foi possivel baixar evolution-logo.png" -ForegroundColor Yellow
    }
}

# Corrigir index.html
$indexHtml = Join-Path $ManagerDist "index.html"
if (Test-Path $indexHtml) {
    $html = Get-Content $indexHtml -Raw
    $html = $html -replace 'https://evolution-api\.com/files/evo/favicon\.svg', '/files/evo/favicon.svg'
    $html = $html -replace 'type="image/png" href="/files/evo/favicon\.svg"', 'type="image/svg+xml" href="/files/evo/favicon.svg"'
    Set-Content $indexHtml $html -NoNewline
}

# Corrigir bundle JS
Get-ChildItem (Join-Path $ManagerDist "assets") -Filter "index-*.js" -ErrorAction SilentlyContinue | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $updated = $content.Replace('https://evolution-api.com/files/evo/', '/files/evo/')
    if ($updated -ne $content) {
        Set-Content $_.FullName $updated -NoNewline
        Write-Host "Patch aplicado: $($_.Name)" -ForegroundColor Green
    }
}

Write-Host "Assets do Manager corrigidos." -ForegroundColor Green
