# Deploy SEM SSH (FTP + instalador web + cPanel Node.js)

Fluxo para hospedagem **cPanel** sem acesso SSH.

## Limite importante

A Evolution API e um processo **Node.js permanente**. Sem SSH, o unico caminho estavel e:

1. Upload por FTP
2. Instalador web (`install.php`) para `.env` + banco + `.htaccess`
3. **Setup Node.js App** do cPanel para `npm install` e Start

PHP sozinho **nao** mantem WhatsApp conectado.

---

## Passo 1 — No seu PC

```powershell
cd c:\laragon\www\evolution
copy .env.production.example .env.production
notepad .env.production
.\scripts\build-release.ps1
```

Gera `release\upload\` e `release\evolution-api-upload.zip`.

---

## Passo 2 — Banco (phpMyAdmin)

1. Crie o banco/usuario no cPanel (se ainda nao existir)
2. phpMyAdmin → Importar → envie `schema.sql` do pacote

(O instalador web tambem pode importar o schema.)

---

## Passo 3 — Upload FTP

Envie **todo** o conteudo de `release\upload\` para:

`public_html/evolution/` (ou a pasta do subdominio)

Inclui: `dist/`, `manager/`, `prisma/`, `package.json`, `.env`, `schema.sql`, **`install.php`**

---

## Passo 4 — Instalador web

Abra no navegador:

`https://evolution.epage.app.br/install.php`

Preencha MySQL, URL e API Key → **Instalar configuracao**.

Isso grava `.env`, `.htaccess` e (se o PHP permitir) tenta `npm install`.

---

## Passo 5 — Node.js App do cPanel (obrigatorio)

1. cPanel → **Setup Node.js App** → Create Application
2. Preencha:
   - **Node version:** 20+
   - **Application root:** pasta do upload (ex: `evolution`)
   - **Application URL:** `evolution.epage.app.br`
   - **Startup file:** `dist/main.js`
3. **Run NPM Install**
4. **Start / Restart**
5. Teste: `https://evolution.epage.app.br/` deve responder JSON

---

## Passo 6 — Limpeza

Apague `install.php` do servidor.

---

## Se der 404 depois do install

| Causa | Solucao |
|-------|---------|
| Node App parado | Start no cPanel |
| Startup file errado | Use `dist/main.js` |
| Proxy Apache | Confira `.htaccess` gerado pelo instalador |
| Redis ausente | Ative Redis no painel ou desabilite cache (nao recomendado) |

---

## Comparativo

| Metodo | SSH | FTP | cPanel Node |
|--------|-----|-----|-------------|
| `install-no-servidor.sh` | Sim | Sim | Nao precisa |
| `install.php` (este) | **Nao** | Sim | **Sim** |
