# Evolution API — Instalação nativa (sem Docker)

Instalação para **Windows + Laragon**, usando MySQL, Redis e Node.js — sem Docker.

## O que você precisa

| Componente | Status na sua máquina |
|------------|----------------------|
| **Node.js** | Já instalado (v24) |
| **Git** | Já instalado |
| **MySQL** | Laragon (`C:\laragon\bin\mysql`) |
| **Redis** | Laragon (`C:\laragon\bin\redis`) |
| **Docker** | **Não necessário** |

## Início rápido

### 1. Inicie os serviços no Laragon

Abra o **Laragon** e clique em **Start All** (ou inicie **MySQL** e **Redis**).

### 2. Instale a Evolution API

```powershell
cd c:\laragon\www\evolution
.\scripts\setup-native.ps1
```

Esse script:
- Cria o banco `evolution` no MySQL
- Clona o repositório oficial (v2.3.7) em `api/`
- Instala dependências (`npm install`)
- Aplica migrations do banco
- Compila o projeto

### 3. Inicie a API

```powershell
.\scripts\start-native.ps1
```

> **Configurar instância WhatsApp:** veja [docs/CONFIGURACAO-INSTANCIA.md](docs/CONFIGURACAO-INSTANCIA.md)

### Acessos

| Serviço | URL |
|---------|-----|
| API | http://localhost:8080 |
| Manager (painel) | http://localhost:8080/manager |
| Documentação | http://localhost:8080/docs |

### Autenticação

Header em todas as requisições:

```
apikey: SUA_AUTHENTICATION_API_KEY
```

A chave está no arquivo `.env`.

---

## Produção (sem Docker)

1. Mantenha MySQL e Redis rodando (serviço Windows ou Laragon em modo produção).
2. Use **PM2** ou **NSSM** para manter a API sempre ativa:

```powershell
cd c:\laragon\www\evolution\api
npm install -g pm2
pm2 start npm --name "evolution-api" -- run start:prod
pm2 save
```

3. Configure o **Nginx do Laragon** como reverse proxy com HTTPS.
4. Ajuste no `.env`:
   - `SERVER_URL=https://api.seudominio.com`

---

## Instalação com Docker (opcional)

Se no futuro quiser usar Docker, os arquivos `docker-compose.yml` e `scripts/start.ps1` continuam disponíveis. Veja a seção Docker no histórico do projeto ou execute:

```powershell
.\scripts\setup.ps1
.\scripts\start.ps1
```

---

## Estrutura

```
evolution/
├── api/                      # Codigo da Evolution API (clone git)
├── .env                      # Configuracao (MySQL + Redis local)
├── .env.native.example       # Modelo para instalacao nativa
├── scripts/
│   ├── setup-native.ps1      # Instala tudo (sem Docker)
│   └── start-native.ps1      # Inicia Redis + API
├── docker-compose.yml        # Opcional (Docker)
└── backups/
```

## Comandos úteis

```powershell
# Reinstalar dependencias
cd api
npm install
npx tsup

# Atualizar migrations (se necessario)
# Remova prisma\migrations e copie de prisma\mysql-migrations antes do deploy

# Desenvolvimento com hot reload
npm run dev:server
```

## Solução de problemas

**MySQL não conecta** — Verifique se o Laragon está com MySQL iniciado.

**Redis recusou conexão** — Inicie o Redis no Laragon ou o script `start-native.ps1` tenta iniciar automaticamente.

**Porta 8080 em uso** — Altere `SERVER_PORT` e `SERVER_URL` no `.env`.

**Erro no `npm install`** — Execute `npm install --legacy-peer-deps` dentro de `api/`.

## Links

- [Documentação oficial](https://docs.evolutionfoundation.com.br/)
- [Repositório GitHub](https://github.com/evolution-foundation/evolution-api)
