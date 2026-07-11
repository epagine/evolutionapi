# Deploy em Produção - Passo a Passo

**Domínio:** https://evolution.epage.app.br/  
**Projeto:** Evolution API v2.3.7  
**Ambiente:** Linux VPS (recomendado) ou servidor com Node.js + PM2 + Nginx  

---

## Pré-requisitos no servidor

- [ ] SSH/acesso ao servidor
- [ ] Node.js v20+ instalado
- [ ] MySQL 8.0+
- [ ] Redis 6.0+
- [ ] Git instalado
- [ ] Domínio com DNS apontando para o servidor
- [ ] SSL/HTTPS configurado (recomendado: Let's Encrypt + Certbot)

---

## Etapa 1: Preparar o servidor

```bash
# SSH no servidor
ssh usuario@seu-servidor.com

# Criar pasta para o projeto
sudo mkdir -p /var/www/evolution
cd /var/www/evolution

# Garantir permissões
sudo chown -R usuario:usuario /var/www/evolution
```

---

## Etapa 2: Clonar o repositório

```bash
git clone https://github.com/epagine/evolutionapi.git .
cd /var/www/evolution
```

---

## Etapa 3: Configurar o arquivo .env

Copie o arquivo de exemplo e ajuste com as credenciais reais:

```bash
cp .env.example .env
nano .env
```

**Valores críticos a alterar:**

```env
# Autenticação
AUTHENTICATION_API_KEY=SUA_CHAVE_API_AQUI

# Banco de dados (MySQL)
DATABASE_CONNECTION_URI=mysql://usuario:senha@localhost:3306/evolution

# Redis
CACHE_REDIS_URI=redis://localhost:6379/0

# URL pública
SERVER_URL=https://evolution.epage.app.br
SERVER_PORT=3000

# Modo
NODE_ENV=production
```

---

## Etapa 4: Instalar dependências e compilar

```bash
cd /var/www/evolution/api

# Instalar dependências
npm install --legacy-peer-deps

# Compilar
npm run build
```

---

## Etapa 5: Configurar o banco de dados

```bash
# Gerar schema
npm run db:generate

# Executar migrations
npm run db:deploy

# Se houver erro, tente:
# rm -rf prisma/migrations
# cp -r prisma/mysql-migrations prisma/migrations
# npx prisma migrate deploy --schema ./prisma/mysql-schema.prisma
```

---

## Etapa 6: Instalar e configurar PM2

```bash
# Instalar PM2 globalmente
sudo npm install -g pm2

# Iniciar a API com PM2
cd /var/www/evolution/api
pm2 start npm --name "evolution-api" -- run start:prod

# Salvar configuração para reiniciar automaticamente
pm2 save

# Configurar PM2 para iniciar no boot
pm2 startup systemd -u usuario --hp /home/usuario
```

---

## Etapa 7: Configurar Nginx como proxy reverso

```bash
# Editar configuração do Nginx
sudo nano /etc/nginx/sites-available/evolution

# Adicionar:
```

```nginx
server {
    listen 80;
    server_name evolution.epage.app.br;
    
    # Redirecionar HTTP para HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name evolution.epage.app.br;
    
    # SSL (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/evolution.epage.app.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/evolution.epage.app.br/privkey.pem;
    
    # Proxy reverso
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
```

```bash
# Habilitar o site
sudo ln -s /etc/nginx/sites-available/evolution /etc/nginx/sites-enabled/

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
```

---

## Etapa 8: Configurar SSL (se não tiver)

```bash
# Instalar Certbot
sudo apt-get install certbot python3-certbot-nginx

# Gerar certificado
sudo certbot certonly --standalone -d evolution.epage.app.br

# Auto-renewal
sudo certbot renew --dry-run
```

---

## Etapa 9: Validação

```bash
# Verificar status do PM2
pm2 status

# Ver logs da API
pm2 logs evolution-api

# Testar endpoint local
curl http://localhost:3000/

# Testar via domínio
curl https://evolution.epage.app.br/
```

---

## Etapa 10: Verificação final

- [ ] `curl https://evolution.epage.app.br/` retorna algo diferente de 404
- [ ] `pm2 status` mostra `evolution-api` online
- [ ] `/manager` acessível
- [ ] `/docs` acessível
- [ ] MySQL e Redis conectando
- [ ] Logs sem erros críticos

---

## Monitoramento contínuo

```bash
# Ver logs em tempo real
pm2 logs evolution-api

# Reiniciar se necessário
pm2 restart evolution-api

# Status geral
pm2 status
```

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Porta 3000 em uso | `sudo lsof -i :3000` e matar processo |
| Erro de conexão MySQL | Verificar credenciais em `.env` e se MySQL está rodando |
| Redis não conecta | Verificar `redis-cli ping` no servidor |
| 502 Bad Gateway do Nginx | Verificar `pm2 logs` e status da API |
| Certificado SSL expirado | Rodar `sudo certbot renew` |

---

## Comandos úteis para manutenção

```bash
# Atualizar código do GitHub
cd /var/www/evolution
git pull origin main

# Recompilar
cd api && npm run build

# Reiniciar API
pm2 restart evolution-api

# Backup do banco
mysqldump -u usuario -p evolution > /var/www/evolution/backups/evolution-$(date +%Y%m%d_%H%M%S).sql
```

---

## Suporte

Documentação oficial: https://docs.evolutionfoundation.com.br/
Repositório: https://github.com/evolution-foundation/evolution-api
