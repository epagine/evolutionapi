# Deploy por upload (build local → servidor)

Prepare tudo no **Windows/Laragon** e envie só os arquivos prontos ao servidor.

## Por que nao copiar node_modules?

Modulos nativos (`sharp`, etc.) compilados no **Windows nao funcionam no Linux**.
O pacote vai **sem** `node_modules`; o servidor instala com um script (~2 min).

---

## Passo 1 — Configurar producao localmente

```powershell
cd c:\laragon\www\evolution
copy .env.production.example .env.production
notepad .env.production
```

Preencha:

```env
SERVER_URL=https://evolution.epage.app.br
DATABASE_CONNECTION_URI=mysql://us_evolution:SENHA@127.0.0.1:3306/db_evolution
AUTHENTICATION_API_KEY=sua_chave_forte
```

---

## Passo 2 — Gerar pacote

```powershell
.\scripts\build-release.ps1
```

Gera:

| Saida | Conteudo |
|-------|----------|
| `release/upload/` | Pasta para enviar via FTP |
| `release/evolution-api-upload.zip` | Mesmo conteudo compactado |

Inclui: `dist/`, `manager/`, `public/`, `prisma/`, `.env`, `schema.sql`, `install-no-servidor.sh`

---

## Passo 3 — Banco no servidor (uma vez)

No **phpMyAdmin** ou terminal:

```bash
mysql -u us_evolution -p db_evolution < schema.sql
```

(Use o `schema.sql` que veio dentro do pacote.)

---

## Passo 4 — Enviar arquivos

Via **FTP/SFTP** (FileZilla, cPanel):

- Envie **todo o conteudo** de `release/upload/` para o servidor
- Exemplo cPanel: `public_html/evolution/`

**Nao envie** a pasta `node_modules` do seu PC.

---

## Passo 5 — Instalar no servidor (SSH)

```bash
cd ~/public_html/evolution
chmod +x install-no-servidor.sh
bash install-no-servidor.sh
```

O script:
1. `npm install` (Linux)
2. Gera Prisma Client
3. Inicia com PM2 na porta **8080**

Teste:

```bash
curl http://127.0.0.1:8080
```

---

## Passo 6 — Proxy reverso

O dominio precisa apontar para `127.0.0.1:8080`.

### Apache (.htaccess)

```apache
RewriteEngine On
RewriteCond %{HTTP:Upgrade} websocket [NC]
RewriteCond %{HTTP:Connection} upgrade [NC]
RewriteRule ^/?(.*) ws://127.0.0.1:8080/$1 [P,L]
RewriteRule ^(.*)$ http://127.0.0.1:8080/$1 [P,L]
```

### Nginx

```nginx
location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

---

## Atualizar versao depois

1. Edite `.env.production` se necessario
2. `.\scripts\build-release.ps1`
3. Envie arquivos novos (substitua no servidor)
4. No servidor: `bash install-no-servidor.sh`

---

## Checklist

- [ ] `.env.production` com dominio e MySQL corretos
- [ ] `build-release.ps1` executado sem erro
- [ ] `schema.sql` importado no MySQL
- [ ] Arquivos enviados via FTP
- [ ] `install-no-servidor.sh` executado
- [ ] `curl http://127.0.0.1:8080` OK
- [ ] Proxy Apache/Nginx configurado
- [ ] Redis rodando no servidor
