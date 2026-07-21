# Deploy na Hostoo (GitHub automatico)

## Em portugues simples

A Hostoo copia do GitHub **so o que esta no repositorio**.

Hoje o GitHub tem:

- scripts, docs, schema
- **NAO tem** o programa da Evolution API (`api/` fica so no seu PC)

Por isso o site da **404**: a Hostoo sincroniza pastas vazias de sentido (README, scripts), mas **nao tem o sistema ligado**.

```
Seu PC  -->  GitHub  -->  Hostoo
              |
              so o que esta commitado
```

---

## O que a Hostoo precisa (2 coisas)

### 1) Arquivos do programa no GitHub
Pasta com `package.json`, `dist/`, `manager/`, `prisma/`, etc.

### 2) App Node.js ligado no painel Hostoo
Mesmo com os arquivos certos, precisa **criar/ligar o aplicativo Node.js** no painel (igual ligar um servico).  
O Git so **envia arquivos**. Quem **liga** o WhatsApp e o Node do painel.

Guia oficial Hostoo: [Como usar Node.js na hospedagem](https://help.hostoo.io/)

---

## Fluxo certo (sem voce precisar saber Node)

### A) Uma vez no painel Hostoo

1. Crie o banco MySQL (`db_evolution` / `us_evolution`)
2. Importe `database/schema.sql` no phpMyAdmin
3. Em **Node.js** / aplicativo:
   - pasta do projeto (onde o Git faz deploy)
   - arquivo de inicio: `dist/main.js`
   - versao Node 20+
4. Coloque as variaveis de ambiente (ou `.env` no servidor, **fora do Git**):
   - `SERVER_URL=https://evolution.epage.app.br`
   - `DATABASE_CONNECTION_URI=mysql://USUARIO:SENHA@127.0.0.1:3306/db_evolution`
   - `AUTHENTICATION_API_KEY=sua_chave`
   - Redis (se a Hostoo tiver Redis)

### B) No seu PC (quando formos ajustar o GitHub)

Vamos colocar o **programa compilado** no repositorio (sem senhas).  
Ai cada `git push` a Hostoo atualiza sozinha.

### C) Depois do push

No painel Hostoo: **Restart** do app Node.js (se nao reiniciar sozinho).

---

## O que NUNCA vai no GitHub

- `.env` com senha e API key
- `node_modules` (a Hostoo instala no servidor)
- sessoes WhatsApp (`instances/`)

Esses ficam **so no servidor** / painel.

---

## Checklist Hostoo

- [ ] Banco criado + schema importado
- [ ] App Node.js criado no painel (startup `dist/main.js`)
- [ ] Variaveis / `.env` de producao no servidor
- [ ] Redis disponivel (pergunte ao suporte Hostoo se o plano tem)
- [ ] Repositorio GitHub com a pasta do programa (nao so docs)
- [ ] Deploy automatico apontando para a branch `main`
- [ ] Apos push: Restart do Node se precisar
- [ ] Teste: https://evolution.epage.app.br deve mostrar JSON

---

## Resumo

| O que voce pensava | O que acontece de verdade |
|--------------------|---------------------------|
| Push no GitHub = site no ar | Push = **copia arquivos** |
| Arquivos = Evolution funcionando | Precisa **Node ligado** no painel |
| Repo atual basta | Falta o **programa** no GitHub |

Proximo passo: preparar o repositorio para a Hostoo (incluir o app compilado, sem senhas) e voce so da push.
