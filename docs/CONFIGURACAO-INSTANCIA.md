# Configuração correta da instância — Evolution API

Guia prático para criar, conectar e configurar instâncias WhatsApp neste projeto (instalação nativa Laragon, sem Docker).

---

## Pré-requisitos

Antes de criar uma instância, confirme:

| Item | Como verificar |
|------|----------------|
| MySQL rodando | Laragon → **Start All** |
| Redis rodando | Laragon → **Start All** |
| API ativa | http://localhost:8080 retorna JSON de boas-vindas |
| API Key | Valor de `AUTHENTICATION_API_KEY` no arquivo `.env` |

**URLs do ambiente local:**

| Recurso | URL |
|---------|-----|
| API | http://localhost:8080 |
| Manager (painel) | http://localhost:8080/manager |
| Documentação interativa | http://localhost:8080/docs |

---

## Autenticação

Todas as requisições exigem o header:

```http
apikey: SUA_AUTHENTICATION_API_KEY
Content-Type: application/json
```

> A chave está em `.env` → `AUTHENTICATION_API_KEY`. **Nunca** compartilhe ou commite essa chave.

---

## Tipos de integração

| Integração | Quando usar |
|------------|-------------|
| `WHATSAPP-BAILEYS` | **Padrão** — WhatsApp Web via QR Code. Ideal para testes e a maioria dos casos. |
| `WHATSAPP-BUSINESS` | API oficial Meta (Cloud API). Requer credenciais Facebook/Meta. |
| `EVOLUTION` | Canal interno Evolution (integrações específicas). |

Para este projeto, use **`WHATSAPP-BAILEYS`**.

---

## Criar instância (recomendado para testes)

### Opção A — Pelo Manager (visual)

1. Acesse http://localhost:8080/manager
2. Informe a **URL da API**: `http://localhost:8080`
3. Informe a **API Key** do `.env`
4. Clique em **Create Instance**
5. Preencha:
   - **Instance Name**: nome único, sem espaços (ex: `atendimento`, `loja-teste`)
   - **Integration**: `WHATSAPP-BAILEYS`
6. Escaneie o **QR Code** com o WhatsApp do celular (Aparelhos conectados → Conectar aparelho)

### Opção B — Pela API (PowerShell)

Substitua `SUA_API_KEY` e o nome da instância:

```powershell
$headers = @{
    apikey = "SUA_API_KEY"
}

$body = @{
    instanceName = "atendimento"
    integration  = "WHATSAPP-BAILEYS"
    qrcode       = $true
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://localhost:8080/instance/create" `
    -Method POST `
    -Headers $headers `
    -Body $body `
    -ContentType "application/json"
```

Resposta esperada: status `201` com dados da instância e QR Code (base64 ou pairing code, conforme versão).

---

## Configuração recomendada por ambiente

### Testes / desenvolvimento

```json
{
  "instanceName": "atendimento-teste",
  "integration": "WHATSAPP-BAILEYS",
  "qrcode": true,
  "rejectCall": false,
  "groupsIgnore": true,
  "alwaysOnline": false,
  "readMessages": false,
  "readStatus": false,
  "syncFullHistory": false
}
```

| Campo | Valor teste | Motivo |
|-------|-------------|--------|
| `groupsIgnore` | `true` | Evita processar mensagens de grupos durante testes |
| `alwaysOnline` | `false` | Comportamento mais próximo do uso normal |
| `readMessages` | `false` | Não marca mensagens como lidas automaticamente |
| `readStatus` | `false` | Não envia confirmação de leitura de status |
| `syncFullHistory` | `false` | Conexão mais rápida; não sincroniza histórico completo |

### Produção / atendimento

```json
{
  "instanceName": "atendimento-prod",
  "integration": "WHATSAPP-BAILEYS",
  "qrcode": true,
  "rejectCall": true,
  "msgCall": "No momento não atendemos ligações. Envie uma mensagem.",
  "groupsIgnore": true,
  "alwaysOnline": true,
  "readMessages": true,
  "readStatus": false,
  "syncFullHistory": false
}
```

| Campo | Valor prod | Motivo |
|-------|------------|--------|
| `rejectCall` | `true` | Bloqueia ligações de voz/vídeo |
| `msgCall` | texto | Resposta automática ao recusar ligação |
| `alwaysOnline` | `true` | Mantém status "online" |
| `readMessages` | `true` | Marca mensagens recebidas como lidas (útil com CRM/bot) |
| `groupsIgnore` | `true` | Foco em conversas individuais (ajuste se precisar de grupos) |

---

## Ajustar configurações depois de criada

### Consultar configurações atuais

```http
GET /settings/find/atendimento
apikey: SUA_API_KEY
```

### Atualizar configurações

```http
POST /settings/set/atendimento
apikey: SUA_API_KEY
Content-Type: application/json
```

```json
{
  "rejectCall": true,
  "msgCall": "Envie uma mensagem de texto.",
  "groupsIgnore": true,
  "alwaysOnline": true,
  "readMessages": true,
  "readStatus": false,
  "syncFullHistory": false
}
```

---

## Webhook (receber eventos no seu sistema)

Configure na **criação** da instância ou depois via endpoint de webhook.

### Exemplo na criação

```json
{
  "instanceName": "atendimento",
  "integration": "WHATSAPP-BAILEYS",
  "qrcode": true,
  "webhook": {
    "url": "https://seu-sistema.com/webhook/evolution",
    "enabled": true,
    "webhookByEvents": false,
    "webhookBase64": false,
    "events": [
      "CONNECTION_UPDATE",
      "QRCODE_UPDATED",
      "MESSAGES_UPSERT",
      "SEND_MESSAGE"
    ]
  }
}
```

### Eventos mais usados

| Evento | Quando dispara |
|--------|------------------|
| `CONNECTION_UPDATE` | Conectou, desconectou ou perdeu sessão |
| `QRCODE_UPDATED` | Novo QR Code gerado |
| `MESSAGES_UPSERT` | Mensagem recebida ou nova no chat |
| `MESSAGES_UPDATE` | Status da mensagem alterado (entregue, lida) |
| `SEND_MESSAGE` | Confirmação de envio |
| `CONTACTS_UPSERT` | Contato criado/atualizado |

### Boas práticas de webhook

- Use **HTTPS** em produção (WhatsApp + segurança).
- Responda com **HTTP 200** em até 60 segundos.
- Implemente **idempotência** (mesmo evento pode chegar mais de uma vez).
- Em testes locais, use [ngrok](https://ngrok.com) ou similar para expor seu webhook.

> No `.env` global, `WEBHOOK_GLOBAL_ENABLED=false`. Webhooks são configurados **por instância**.

---

## Fluxo de conexão (QR Code)

```
1. Criar instância     →  POST /instance/create
2. Obter QR Code       →  GET /instance/connect/{instanceName}
3. Escanear no celular →  WhatsApp → Aparelhos conectados
4. Verificar status    →  GET /instance/connectionState/{instanceName}
```

### Status de conexão

| Status | Significado |
|--------|-------------|
| `open` | Conectado e pronto para enviar/receber |
| `close` | Desconectado |
| `connecting` | Aguardando QR Code ou reconectando |

### Endpoints úteis

| Ação | Método | Endpoint |
|------|--------|----------|
| Listar instâncias | GET | `/instance/fetchInstances` |
| Conectar / QR | GET | `/instance/connect/{instanceName}` |
| Status | GET | `/instance/connectionState/{instanceName}` |
| Reiniciar | POST | `/instance/restart/{instanceName}` |
| Deslogar | DELETE | `/instance/logout/{instanceName}` |
| Excluir | DELETE | `/instance/delete/{instanceName}` |

---

## Enviar mensagem de teste

Após status `open`:

```http
POST /message/sendText/atendimento
apikey: SUA_API_KEY
Content-Type: application/json
```

```json
{
  "number": "5511999999999",
  "text": "Olá! Teste Evolution API."
}
```

> **Número**: DDI + DDD + número, sem `+`, espaços ou traços. Ex: `5511999999999`.

PowerShell:

```powershell
$headers = @{ apikey = "SUA_API_KEY" }
$body = @{
    number = "5511999999999"
    text   = "Olá! Teste Evolution API."
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://localhost:8080/message/sendText/atendimento" `
    -Method POST `
    -Headers $headers `
    -Body $body `
    -ContentType "application/json"
```

---

## Regras importantes do nome da instância

- Use apenas **letras, números, hífen e underscore**
- Sem espaços (ex: `atendimento-loja`, não `Atendimento Loja`)
- Nome **único** por instalação
- Escolha um nome estável — integrações externas referenciam esse nome nas URLs

---

## Checklist antes de ir para produção

- [ ] `SERVER_URL` no `.env` aponta para o domínio público (`https://api.seudominio.com`)
- [ ] API Key forte e exclusiva (regenerar se vazou)
- [ ] HTTPS ativo (Nginx/Caddy no Laragon ou servidor)
- [ ] Webhook com URL pública e HTTPS
- [ ] `groupsIgnore` definido conforme necessidade do negócio
- [ ] Backup do banco MySQL (`evolution`) configurado
- [ ] PM2 ou serviço Windows para manter a API sempre ativa
- [ ] Redis e MySQL iniciando automaticamente com o servidor

---

## Problemas comuns

### WebSocket falha (`ws://localhost:8080/socket.io`)

O Manager usa WebSocket para atualizações em tempo real. Se aparecer `WebSocket connection failed`:

1. Confirme no `.env`:
   ```env
   WEBSOCKET_ENABLED=true
   WEBSOCKET_GLOBAL_EVENTS=true
   ```
2. **Reinicie a API** (alterar o `.env` não basta sem reiniciar):
   ```powershell
   # Ctrl+C no terminal da API, depois:
   .\scripts\start-native.ps1
   ```
3. Recarregue o Manager (F5)

Nos logs da API deve aparecer: `Socket.io initialized`.

### Aba Chat retorna erro 500 (`findChats`)

Com **MySQL** (Laragon), a query original da Evolution API usa SQL de PostgreSQL e falha. Este projeto inclui correção em `api/src/api/services/channel.service.ts` (`fetchChatsMysql`).

Após atualizar o código-fonte, recompile e reinicie:

```powershell
cd api
npx tsup
cd ..
.\scripts\start-native.ps1
```

### WhatsApp conectou, mas o Manager ainda pede QR Code

A conexão pode estar **ativa na API** mesmo com a tela do Manager desatualizada.

**Confirme pelo terminal:**

```powershell
$headers = @{ apikey = "SUA_API_KEY" }
Invoke-RestMethod -Uri "http://localhost:8080/instance/fetchInstances" -Headers $headers
```

Se `connectionStatus` for **`open`**, a instância está conectada. O Manager só não atualizou a interface.

**Solução imediata:**

1. Feche o modal do QR Code (X)
2. Recarregue a página do Manager (**F5** ou Ctrl+Shift+R)
3. A instância deve aparecer como **Conectada**

**Para evitar no futuro:** mantenha no `.env`:

```env
WEBSOCKET_ENABLED=true
WEBSOCKET_GLOBAL_EVENTS=true
```

Depois reinicie a API (`Ctrl+C` no terminal e rode `.\scripts\start-native.ps1` novamente). O WebSocket permite ao Manager receber o evento de conexão em tempo real.

### QR Code não aparece

- Confirme `integration: "WHATSAPP-BAILEYS"` e `qrcode: true`
- Chame `GET /instance/connect/{instanceName}`
- Verifique logs: terminal onde roda `start-native.ps1`

### Instância cai após conectar

- Redis precisa estar ativo (sessão usa cache)
- Não escaneie o mesmo número em duas instâncias ao mesmo tempo
- Verifique se o celular tem internet

### Erro 401 / Unauthorized

- Header `apikey` ausente ou incorreto
- Confira valor em `.env` → `AUTHENTICATION_API_KEY`

### Mensagem não envia

- Status deve ser `open`: `GET /instance/connectionState/{instanceName}`
- Número no formato internacional correto
- Para números BR: `55` + DDD + número (ex: `5511987654321`)

### Webhook não recebe eventos

- URL acessível publicamente (localhost não funciona em produção)
- Eventos corretos listados em `webhook.events`
- Firewall/proxy não bloqueando POST externo

---

## Referências

- [README do projeto](../README.md) — instalação e comandos
- [Documentação oficial Evolution](https://docs.evolutionfoundation.com.br/)
- [Postman Collection](https://evolution-api.com/postman)
