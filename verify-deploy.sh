#!/bin/bash

##############################################################################
# Script de Verificação e Troubleshooting
# Uso: bash verify-deploy.sh
##############################################################################

echo "========================================"
echo "🔍 Verificação de Deploy"
echo "========================================"
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_ok() { echo -e "${GREEN}✓${NC} $1"; }
check_fail() { echo -e "${RED}✗${NC} $1"; }
check_warn() { echo -e "${YELLOW}⚠${NC} $1"; }

##############################################################################
# Verificações
##############################################################################

echo "Verificações de sistema:"
echo ""

# Node.js
if command -v node >/dev/null 2>&1; then
    check_ok "Node.js: $(node --version)"
else
    check_fail "Node.js não encontrado"
fi

# npm
if command -v npm >/dev/null 2>&1; then
    check_ok "npm: $(npm --version)"
else
    check_fail "npm não encontrado"
fi

# PM2
if command -v pm2 >/dev/null 2>&1; then
    check_ok "PM2: $(pm2 --version)"
else
    check_fail "PM2 não encontrado"
fi

# Nginx
if command -v nginx >/dev/null 2>&1; then
    check_ok "Nginx: $(nginx -v 2>&1 | cut -d' ' -f3)"
else
    check_fail "Nginx não encontrado"
fi

echo ""
echo "Verificações de banco de dados:"
echo ""

# MySQL
if mysql -uroot -e "SELECT 1" >/dev/null 2>&1; then
    check_ok "MySQL conectando"
else
    check_fail "MySQL não está acessível"
fi

# Redis
if redis-cli ping >/dev/null 2>&1; then
    check_ok "Redis conectando"
else
    check_fail "Redis não está acessível"
fi

# Database
if mysql -uroot -e "USE evolution; SELECT 1" >/dev/null 2>&1; then
    check_ok "Database 'evolution' existe"
else
    check_fail "Database 'evolution' não encontrada"
fi

echo ""
echo "Verificações de aplicação:"
echo ""

# PM2 status
if pm2 status >/dev/null 2>&1; then
    APP_STATUS=$(pm2 status | grep "evolution-api" | awk '{print $2}')
    if [ "$APP_STATUS" = "online" ]; then
        check_ok "PM2: evolution-api online"
    else
        check_fail "PM2: evolution-api $APP_STATUS"
    fi
else
    check_fail "PM2 não respondendo"
fi

echo ""
echo "Verificações de rede:"
echo ""

# Porta 3000 (API)
if netstat -tuln 2>/dev/null | grep -q ":3000 "; then
    check_ok "Porta 3000 (API) em listen"
else
    check_fail "Porta 3000 não está em listen"
fi

# Porta 80 (HTTP)
if netstat -tuln 2>/dev/null | grep -q ":80 "; then
    check_ok "Porta 80 (HTTP) em listen"
else
    check_fail "Porta 80 não está em listen"
fi

# Porta 443 (HTTPS)
if netstat -tuln 2>/dev/null | grep -q ":443 "; then
    check_ok "Porta 443 (HTTPS) em listen"
else
    check_warn "Porta 443 não está em listen (SSL não configurado?)"
fi

echo ""
echo "Verificações de conectividade:"
echo ""

# API local
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    check_ok "API local respondendo (http://localhost:3000)"
else
    check_fail "API local não respondendo"
fi

# Nginx
if curl -s http://localhost > /dev/null 2>&1; then
    check_ok "Nginx respondendo (http://localhost)"
else
    check_fail "Nginx não respondendo"
fi

echo ""
echo "========================================"
echo "Informações úteis:"
echo ""
echo "Ver logs da API:"
echo "  pm2 logs evolution-api"
echo ""
echo "Reiniciar aplicação:"
echo "  pm2 restart evolution-api"
echo ""
echo "Ver status PM2:"
echo "  pm2 status"
echo ""
echo "Ver erros do Nginx:"
echo "  sudo tail -50 /var/log/nginx/error.log"
echo ""
echo "Testar configuração Nginx:"
echo "  sudo nginx -t"
echo ""
echo "Conectar SSH novamente:"
echo "  pm2 kill  # parar PM2"
echo "  pm2 start npm --name 'evolution-api' -- run start:prod"
echo ""
echo "========================================"
