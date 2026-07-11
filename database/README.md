# Banco de dados — Evolution API (MySQL)

Schema da Evolution API **v2.3.7** para MySQL 8.x.

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `schema.sql` | Estrutura completa (tabelas, índices, FKs) — **sem dados** |
| `README.md` | Este guia |

## Produção — criar banco do zero

### 1. Criar banco e usuário

```sql
CREATE DATABASE IF NOT EXISTS evolution
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'evolution'@'localhost' IDENTIFIED BY 'SUA_SENHA_FORTE';
GRANT ALL PRIVILEGES ON evolution.* TO 'evolution'@'localhost';
FLUSH PRIVILEGES;
```

### 2. Importar schema

```bash
mysql -u evolution -p evolution < database/schema.sql
```

PowerShell (Laragon):

```powershell
Get-Content database\schema.sql | C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe -uevolution -p evolution
```

### 3. Configurar `.env`

```env
DATABASE_PROVIDER=mysql
DATABASE_CONNECTION_URI=mysql://evolution:SUA_SENHA_FORTE@127.0.0.1:3306/evolution
```

---

## Alternativa recomendada (via Prisma)

Se você rodar `.\scripts\setup-native.ps1`, as migrations são aplicadas automaticamente. O `schema.sql` é útil quando:

- O servidor de produção **não tem Node.js** no momento do deploy do banco
- Um DBA precisa revisar/aprovar o schema antes
- Você usa um MySQL gerenciado (RDS, etc.) e importa via painel

---

## Backup e restore

**Backup completo (estrutura + dados):**

```powershell
mysqldump -uroot evolution > backups\backup_completo.sql
```

**Apenas dados** (banco já existe):

```powershell
mysqldump -uroot --no-create-info evolution > backups\backup_dados.sql
```

**Restore:**

```powershell
mysql -uroot evolution < backups\backup_completo.sql
```

---

## Tabelas principais

| Tabela | Função |
|--------|--------|
| `Instance` | Instâncias WhatsApp |
| `Message` | Mensagens |
| `Contact` | Contatos |
| `Chat` | Conversas |
| `Setting` | Configurações da instância |
| `Webhook` | Webhooks |
| `_prisma_migrations` | Controle de versão do schema |

---

## Regenerar schema.sql

Após atualizar a Evolution API e rodar novas migrations:

```powershell
mysqldump -uroot --no-data --routines --triggers evolution > database\schema.sql
```
