#!/bin/bash

##############################################################################
# Deploy Automatizado - Evolution API
# Uso: bash deploy-producao.sh
##############################################################################

set -e  # Parar em qualquer erro

echo "========================================"
echo "🚀 Deploy Evolution API - Modo Automático"
echo "========================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para exibir mensagens
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

##############################################################################
# ETAPA 1: Verificar pré-requisitos
##############################################################################

info "Verificando pré-requisitos..."

command -v git >/dev/null 2>&1 || error "Git não encontrado. Instale com: sudo apt install git"
command -v node >/dev/null 2>&1 || error "Node.js não encontrado. Instale de: https://nodejs.org"
command -v npm >/dev/null 2>&1 || error "npm não encontrado"
command -v mysql >/dev/null 2>&1 || error "MySQL não encontrado. Instale com: sudo apt install mysql-server"
command -v redis-cli >/dev/null 2>&1 || error "Redis não encontrado. Instale com: sudo apt install redis-server"

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
info "Node.js: $NODE_VERSION"
info "npm: $NPM_VERSION"

##############################################################################
# ETAPA 2: Preparar ambiente
##############################################################################

info "Preparando ambiente..."

DEPLOY_DIR="/var/www/evolution"
API_DIR="$DEPLOY_DIR/api"

# Criar pasta se não existir
if [ ! -d "$DEPLOY_DIR" ]; then
    warn "Criando diretório $DEPLOY_DIR..."
    sudo mkdir -p "$DEPLOY_DIR"
    sudo chown -R $USER:$USER "$DEPLOY_DIR"
fi

cd "$DEPLOY_DIR"
info "Diretório de trabalho: $(pwd)"

##############################################################################
# ETAPA 3: Clonar/atualizar repositório
##############################################################################

info "Sincronizando repositório..."

if [ -d ".git" ]; then
    info "Repositório já existe, atualizando..."
    git fetch origin
    git reset --hard origin/main
else
    info "Clonando repositório..."
    git clone https://github.com/epagine/evolutionapi.git .
fi

cd "$DEPLOY_DIR"

##############################################################################
# ETAPA 4: Configurar .env
##############################################################################

info "Configurando .env..."

if [ ! -f ".env" ]; then
    warn ".env não encontrado, criando do .env.example..."
    
    if [ ! -f ".env.example" ]; then
        error ".env.example não encontrado"
    fi
    
    cp .env.example .env
    
    # Gerar API key aleatória
    API_KEY=$(openssl rand -hex 32)
    
    # Atualizar valores padrão (você pode personalizar aqui)
    sed -i "s|ALTERE_ESTA_API_KEY|$API_KEY|g" .env
    sed -i "s|DATABASE_CONNECTION_URI=.*|DATABASE_CONNECTION_URI=mysql://root:root@localhost:3306/evolution|g" .env
    sed -i "s|CACHE_REDIS_URI=.*|CACHE_REDIS_URI=redis://localhost:6379/0|g" .env
    sed -i "s|SERVER_URL=.*|SERVER_URL=https://evolution.epage.app.br|g" .env
    sed -i "s|SERVER_PORT=.*|SERVER_PORT=3000|g" .env
    sed -i "s|NODE_ENV=.*|NODE_ENV=production|g" .env
    
    info "✓ .env criado"
    info "  API KEY: $API_KEY"
else
    info ".env já existe, mantendo configuração existente"
fi

##############################################################################
# ETAPA 5: Configurar banco de dados
##############################################################################

info "Verificando MySQL..."

if ! mysql -uroot -e "SELECT 1" >/dev/null 2>&1; then
    error "MySQL não está acessível em localhost"
fi

info "Criando/verificando banco 'evolution'..."
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS evolution CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
info "✓ Banco configurado"

##############################################################################
# ETAPA 6: Verificar Redis
##############################################################################

info "Verificando Redis..."

if ! redis-cli ping >/dev/null 2>&1; then
    error "Redis não está respondendo"
fi

info "✓ Redis conectado"

##############################################################################
# ETAPA 7: Instalar dependências
##############################################################################

info "Instalando dependências (pode demorar ~2-3 min)..."

cd "$API_DIR"
npm install --legacy-peer-deps 2>&1 | tail -5

info "✓ Dependências instaladas"

##############################################################################
# ETAPA 8: Compilar projeto
##############################################################################

info "Compilando projeto..."

npm run build 2>&1 | tail -10

if [ -d "dist" ]; then
    info "✓ Build concluído com sucesso"
else
    error "Build falhou - pasta dist não criada"
fi

##############################################################################
# ETAPA 9: Migrations do banco
##############################################################################

info "Aplicando migrations..."

npm run db:generate 2>&1 | grep -E "(generated|error)" || true

# Limpar migrations antigas
if [ -d "prisma/migrations" ]; then
    rm -rf prisma/migrations
fi

# Copiar migrations do MySQL
if [ -d "prisma/mysql-migrations" ]; then
    cp -r prisma/mysql-migrations prisma/migrations
    info "✓ Migrations copiadas"
fi

# Executar migrations
npm run db:deploy 2>&1 | tail -10

info "✓ Banco de dados configurado"

##############################################################################
# ETAPA 10: Configurar PM2
##############################################################################

info "Configurando PM2..."

# Instalar PM2 globalmente se não tiver
if ! command -v pm2 >/dev/null 2>&1; then
    info "Instalando PM2..."
    sudo npm install -g pm2
fi

# Parar a aplicação anterior se existir
pm2 delete evolution-api 2>/dev/null || true

# Iniciar a aplicação
cd "$API_DIR"
pm2 start npm --name "evolution-api" -- run start:prod
pm2 save

# Configurar PM2 para iniciar no boot
sudo pm2 startup systemd -u $USER --hp /home/$USER || true

info "✓ PM2 configurado"

##############################################################################
# ETAPA 11: Configurar Nginx
##############################################################################

info "Configurando Nginx..."

if ! command -v nginx >/dev/null 2>&1; then
    warn "Nginx não encontrado, instalando..."
    sudo apt-get update -qq
    sudo apt-get install -y nginx 2>&1 | tail -3
fi

# Criar configuração do Nginx
NGINX_CONFIG="/etc/nginx/sites-available/evolution"

sudo tee "$NGINX_CONFIG" > /dev/null <<'EOF'
server {
    listen 80;
    server_name evolution.epage.app.br;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name evolution.epage.app.br;

    # SSL - Configure com Let's Encrypt depois
    # ssl_certificate /etc/letsencrypt/live/evolution.epage.app.br/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/evolution.epage.app.br/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Habilitar site
if [ ! -L "/etc/nginx/sites-enabled/evolution" ]; then
    sudo ln -s /etc/nginx/sites-available/evolution /etc/nginx/sites-enabled/
fi

# Testar configuração
if sudo nginx -t; then
    sudo systemctl restart nginx
    info "✓ Nginx configurado"
else
    error "Erro na configuração do Nginx"
fi

##############################################################################
# ETAPA 12: Configurar SSL (Let's Encrypt)
##############################################################################

info "Verificando SSL..."

if ! command -v certbot >/dev/null 2>&1; then
    warn "Certbot não encontrado"
    warn "Para instalar SSL, execute:"
    warn "  sudo apt-get install certbot python3-certbot-nginx"
    warn "  sudo certbot certonly --standalone -d evolution.epage.app.br"
else
    if [ ! -f "/etc/letsencrypt/live/evolution.epage.app.br/fullchain.pem" ]; then
        warn "Certificado SSL ainda não configurado"
        info "Para configurar, execute:"
        info "  sudo certbot certonly --standalone -d evolution.epage.app.br"
    else
        info "✓ SSL já está configurado"
    fi
fi

##############################################################################
# ETAPA 13: Validação final
##############################################################################

echo ""
echo "========================================"
echo "✅ Deploy concluído!"
echo "========================================"
echo ""

info "Status do PM2:"
pm2 status

echo ""
info "Verificações:"
echo "  • API local: curl http://localhost:3000"
echo "  • Domínio: https://evolution.epage.app.br"
echo "  • Logs: pm2 logs evolution-api"
echo "  • Manager: https://evolution.epage.app.br/manager"
echo ""

info "Próximos passos:"
echo "  1. Configurar SSL (Let's Encrypt):"
echo "     sudo certbot certonly --standalone -d evolution.epage.app.br"
echo ""
echo "  2. Atualizar configuração Nginx com SSL"
echo ""
echo "  3. Validar no navegador:"
echo "     https://evolution.epage.app.br"
echo ""
echo "========================================"
