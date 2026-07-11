# Deploy em producao — evolution.epage.app.br

O erro **404 em https://evolution.epage.app.br/** significa que o **servidor web (Apache/Nginx)** nao esta entregando a Evolution API. Subir apenas os arquivos do Git **nao basta** — a API e um processo **Node.js** na porta 8080.

---

## Diagnostico rapido

| Sintoma | Causa provavel |
|---------|----------------|
| `GET / 404` | Dominio nao aponta para a pasta certa, ou Node nao esta rodando |
| Pasta sem `api/` | Setup nao foi executado no servidor |
| `.env` com `localhost` | `SERVER_URL` incorreto para producao |

---

## Passo 1 — Corrigir o `.env`

```env
SERVER_URL=https://evolution.epage.app.br

MYSQL_DATABASE=db_evolution
MYSQL_USER=us_evolution
MYSQL_PASSWORD=SUA_SENHA

DATABASE_PROVIDER=mysql
DATABASE_CONNECTION_URI=mysql://us_evolution:SUA_SENHA@127.0.0.1:3306/db_evolution
```

> A URI deve usar **o mesmo** usuario, senha e banco de `MYSQL_*`.

---

## Passo 2 — Instalar a Evolution API no servidor (SSH)

```bash
cd ~/public_html/evolution

# Node 20+ necessario
node -v

# Instalar dependencias e clonar API (Linux)
git clone --depth 1 --branch 2.3.7 https://github.com/evolution-foundation/evolution-api.git api
cp .env api/.env

cd api
npm install --legacy-peer-deps
npm install prisma@6.16.2 @prisma/client@6.16.2 --save-exact

# Migrations
npm run db:generate
rm -rf prisma/migrations
cp -r prisma/mysql-migrations prisma/migrations
npx prisma migrate deploy --schema prisma/mysql-schema.prisma

# Patch MySQL (aba Chat)
cd ..
git apply --ignore-whitespace patches/mysql-fetch-chats.patch 2>/dev/null || bash -c "cd api && patch -p1 < ../patches/mysql-fetch-chats.patch"

cd api
npx tsup
```

**Ou importar o banco manualmente:**

```bash
mysql -u us_evolution -p db_evolution < database/schema.sql
```

---

## Passo 3 — Subir a API com PM2

```bash
cd ~/public_html/evolution/api
npm install -g pm2

pm2 start npm --name evolution-api -- run start:prod
pm2 save
pm2 startup
```

Teste **no proprio servidor**:

```bash
curl http://127.0.0.1:8080
```

Resposta esperada: JSON `"Welcome to the Evolution API"`.

---

## Passo 4 — Proxy reverso (Apache)

O dominio precisa **encaminhar** para `http://127.0.0.1:8080`.

### Opcao A — Subdominio aponta para `public_html/evolution`

No cPanel: **Subdominios** → `evolution` → raiz `public_html/evolution`

Crie `.htaccess` em `public_html/evolution`:

```apache
RewriteEngine On
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{HTTP:Connection} upgrade [NC]
RewriteRule ^/?(.*) ws://127.0.0.1:8080/$1 [P,L]

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ http://127.0.0.1:8080/$1 [P,L]
```

Requer modulos `proxy` e `proxy_http` habilitados no Apache.

### Opcao B — Nginx (VPS)

```nginx
server {
    listen 443 ssl http2;
    server_name evolution.epage.app.br;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Passo 5 — Redis

A Evolution API precisa de **Redis**. Confirme no servidor:

```bash
redis-cli ping
```

Se retornar `PONG`, ajuste no `.env`:

```env
CACHE_REDIS_URI=redis://127.0.0.1:6379/0
```

Sem Redis, a API pode falhar ao conectar instancias WhatsApp.

---

## Passo 6 — Node.js na hospedagem

Hospedagem compartilhada **sem SSH/Node** nao roda Evolution API nativamente. Alternativas:

| Hospedagem | Solucao |
|------------|---------|
| VPS (DigitalOcean, Hetzner, etc.) | Node + PM2 + Nginx |
| cPanel com Node.js Selector | Ativar Node 20+ e PM2 |
| Sem Node | Necessita de um host com runtime Node.js |

---

## Checklist final

- [ ] `curl http://127.0.0.1:8080` funciona no servidor
- [ ] `pm2 status` mostra `evolution-api` online
- [ ] `.env` com `SERVER_URL=https://evolution.epage.app.br`
- [ ] `DATABASE_CONNECTION_URI` com `us_evolution` e `db_evolution`
- [ ] Proxy Apache/Nginx configurado
- [ ] SSL (HTTPS) ativo no dominio
- [ ] Redis rodando

---

## URLs apos deploy

| Recurso | URL |
|---------|-----|
| API | https://evolution.epage.app.br |
| Manager | https://evolution.epage.app.br/manager |
| Docs | https://evolution.epage.app.br/docs |

---

## Erro comum: 404 com arquivos no Git

Se no painel voce ve apenas:

```
.git  assets  backups  docs  patches  scripts  README.md  .env
```

**Falta a pasta `api/`** e **nenhum processo Node** esta rodando. O Apache lista arquivos ou retorna 404 — nao executa a API sozinho.
