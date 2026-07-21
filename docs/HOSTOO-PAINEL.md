# O que fazer na Hostoo AGORA (passo a passo)

Voce **nao precisa saber Node**. So clicar no painel.

---

## 1) Banco de dados (uma vez)

1. Painel Hostoo → **MySQL** → crie banco e usuario (se ainda nao criou)
2. Abra **phpMyAdmin**
3. Selecione o banco
4. Aba **Importar** → escolha o arquivo `schema.sql` do projeto → Executar

---

## 2) Esperar o deploy do GitHub

Depois do push, a Hostoo copia os arquivos sozinha.
Confira no Gerenciador de Arquivos se existem:

- `package.json`
- `dist/`
- `manager/`
- `prisma/`

---

## 3) Criar o aplicativo Node.js

1. No painel Hostoo, procure **Node.js**
2. Crie o aplicativo com:

| Campo | Valor |
|--------|--------|
| Pasta / Application root | a pasta do site (onde esta o `package.json`) |
| Arquivo de inicio / Startup | `dist/main.js` |
| Versao | **20** ou superior |
| Comando start (se pedir) | `npm start` |

3. Clique em **Instalar dependencias** / **NPM Install** (espere terminar)
4. Clique em **Iniciar** / **Start**

---

## 4) Colocar as senhas (IMPORTANTE)

As senhas **nao** vao no GitHub.

No painel do app Node (Variaveis de ambiente) ou arquivo `.env` **so no servidor**, use o modelo de `.env.example`:

- `SERVER_URL=https://evolution.epage.app.br`
- `DATABASE_CONNECTION_URI=mysql://USUARIO:SENHA@127.0.0.1:3306/BANCO`
- `AUTHENTICATION_API_KEY=sua_chave`

Se a Hostoo tiver Redis, mantenha:

- `CACHE_REDIS_URI=redis://127.0.0.1:6379/0`

Se **nao** tiver Redis, pergunte ao suporte Hostoo. Sem Redis a Evolution costuma falhar.

---

## 5) Testar

Abra:

https://evolution.epage.app.br

Deve aparecer um texto (JSON). Se aparecer, **funcionou**.

Painel: https://evolution.epage.app.br/manager

---

## 6) Se ainda der 404

1. App Node esta **Start/Online**?
2. Startup file esta `dist/main.js`?
3. NPM Install ja rodou?
4. Reinicie o app Node depois de criar o `.env`
5. Abra um ticket na Hostoo: *"preciso de Node.js 20 + Redis para Evolution API"*

---

## Depois disso

Cada vez que atualizarmos o GitHub, a Hostoo sincroniza.
Se o site nao atualizar sozinho, no painel: **Restart** do Node.js.
