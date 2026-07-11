#!/bin/bash

##############################################################################
# Script de Pós-Deploy: Configurar SSL com Let's Encrypt
# Uso: bash configure-ssl.sh
##############################################################################

set -e

echo "========================================"
echo "🔒 Configurar SSL (Let's Encrypt)"
echo "========================================"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

DOMAIN="evolution.epage.app.br"
NGINX_CONFIG="/etc/nginx/sites-available/evolution"

##############################################################################
# Verificar pré-requisitos
##############################################################################

info "Verificando pré-requisitos..."

if ! command -v certbot >/dev/null 2>&1; then
    info "Instalando Certbot..."
    sudo apt-get update -qq
    sudo apt-get install -y certbot python3-certbot-nginx
fi

if [ ! -f "$NGINX_CONFIG" ]; then
    error "Configuração Nginx não encontrada em $NGINX_CONFIG"
fi

##############################################################################
# Gerar certificado
##############################################################################

info "Gerando certificado SSL para $DOMAIN..."
info "Isso pode demorar alguns segundos..."

sudo certbot certonly \
    --webroot \
    -w /var/www/html \
    -d "$DOMAIN" \
    --non-interactive \
    --agree-tos \
    -m seu-email@dominio.com || {
    
    warn "Falha com --webroot, tentando com standalone..."
    
    # Parar nginx temporariamente
    sudo systemctl stop nginx
    
    sudo certbot certonly \
        --standalone \
        -d "$DOMAIN" \
        --non-interactive \
        --agree-tos \
        -m seu-email@dominio.com
    
    sudo systemctl start nginx
}

##############################################################################
# Atualizar configuração Nginx com SSL
##############################################################################

info "Atualizando configuração Nginx com SSL..."

sudo tee "$NGINX_CONFIG" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # SSL Security
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Testar configuração
if sudo nginx -t; then
    sudo systemctl restart nginx
    info "✓ Nginx reiniciado com SSL"
else
    error "Erro na configuração Nginx"
fi

##############################################################################
# Configurar auto-renewal
##############################################################################

info "Configurando renovação automática..."

sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

info "✓ Auto-renewal configurado"

##############################################################################
# Validação
##############################################################################

echo ""
echo "========================================"
echo "✅ SSL configurado com sucesso!"
echo "========================================"
echo ""

info "Verificações:"
echo "  • Acessar: https://$DOMAIN"
echo "  • Verificar certificado: curl -I https://$DOMAIN"
echo ""

info "Status:"
sudo certbot certificates || true

echo ""
echo "========================================"
