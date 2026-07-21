#!/bin/bash
# Executar NO SERVIDOR (Linux) apos enviar os arquivos via FTP/SFTP
# Uso: cd /caminho/da/pasta && bash install-no-servidor.sh

set -e

echo "=== Evolution API - Instalacao no servidor ==="

command -v node >/dev/null 2>&1 || { echo "ERRO: Node.js nao encontrado. Instale Node 20+."; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "ERRO: npm nao encontrado."; exit 1; }

NODE_MAJOR=$(node -e "console.log(process.version.split('.')[0].replace('v',''))")
if [ "$NODE_MAJOR" -lt 20 ]; then
  echo "ERRO: Node.js 20+ necessario (atual: $(node --version))"
  exit 1
fi

if [ ! -f ".env" ]; then
  echo "ERRO: Arquivo .env nao encontrado nesta pasta."
  exit 1
fi

if [ ! -d "dist" ]; then
  echo "ERRO: Pasta dist/ nao encontrada. Envie o pacote completo do build-release."
  exit 1
fi

echo "[1/4] Instalando dependencias (Linux)..."
npm install --omit=dev --legacy-peer-deps
npm install prisma@6.16.2 @prisma/client@6.16.2 --save-exact --legacy-peer-deps

echo "[2/4] Gerando Prisma Client..."
npx prisma generate --schema prisma/mysql-schema.prisma

echo "[3/4] Testando API localmente..."
timeout 5 node dist/main.js &
PID=$!
sleep 3
if curl -sf http://127.0.0.1:8080 >/dev/null 2>&1; then
  echo "OK - API respondeu na porta 8080"
else
  echo "AVISO - API nao respondeu (verifique MySQL/Redis no .env)"
fi
kill $PID 2>/dev/null || true
wait $PID 2>/dev/null || true

echo "[4/4] Iniciando com PM2..."
if ! command -v pm2 >/dev/null 2>&1; then
  echo "Instalando PM2..."
  npm install -g pm2
fi

pm2 delete evolution-api 2>/dev/null || true
pm2 start npm --name evolution-api -- run start:prod
pm2 save

echo ""
echo "=== Concluido ==="
echo "API rodando em http://127.0.0.1:8080"
echo "Configure o proxy (Apache/Nginx) para apontar para essa porta."
echo ""
echo "Comandos uteis:"
echo "  pm2 logs evolution-api"
echo "  pm2 restart evolution-api"
echo "  pm2 status"
