#Requires -Version 5.1
<#
.SYNOPSIS
    Reinicia a Evolution API (para processo antigo, recompila e sobe de novo).
#>

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ApiDir = Join-Path $Root "api"

Write-Host "=== Reiniciando Evolution API ===" -ForegroundColor Cyan

# Liberar porta 8080
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue |
    Select-Object OwningProcess -Unique |
    ForEach-Object {
        if ($_.OwningProcess -gt 0) {
            Write-Host "Encerrando processo na porta 8080 (PID $($_.OwningProcess))..." -ForegroundColor Yellow
            taskkill /PID $_.OwningProcess /F 2>$null | Out-Null
        }
    }
Start-Sleep -Seconds 2

# Sincronizar .env
Copy-Item (Join-Path $Root ".env") (Join-Path $ApiDir ".env") -Force

# Recompilar (inclui correcoes MySQL do Chat)
Write-Host "Recompilando..." -ForegroundColor Cyan
Set-Location $ApiDir
& "$Root\scripts\apply-mysql-chat-patch.ps1" 2>$null
cmd /c "npx tsup 2>&1" | Out-Null

Set-Location $Root
& "$Root\scripts\start-native.ps1"
