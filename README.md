# Evolution API na Hostoo

Repositorio pronto para **deploy automatico do GitHub** na [Hostoo](https://hostoo.io/).

## O que fazer agora (leia so isto)

1. Espere este codigo chegar na Hostoo (deploy do GitHub)
2. Siga o guia: **[docs/HOSTOO-PAINEL.md](docs/HOSTOO-PAINEL.md)**

Resumo: importar `schema.sql` → criar app Node.js → `dist/main.js` → NPM Install → Start → colocar senhas no servidor.

## Importante

- Senhas ficam **so na Hostoo**, nunca no GitHub
- Modelo das variaveis: `.env.example`
- Banco: arquivo `schema.sql` na raiz

## Desenvolvimento local (Windows/Laragon)

Veja scripts em `scripts/` e `docs/CONFIGURACAO-INSTANCIA.md`.
