# Próximos Passos

## Configuração de produção — concluído

- [x] Criar o projeto Worker e o banco D1 na conta Cloudflare.
- [x] Configurar o `database_id` real no `wrangler.toml`.
- [x] Configurar `FIREBASE_PROJECT_ID` (`pokedex-app-c5e90`).
- [x] Criar e armazenar `CURSOR_ENCRYPTION_KEY` como secret do Worker.
- [x] Configurar `CORS_ALLOWED_ORIGINS` com os domínios Web Firebase.
- [x] Configurar `GAME_API_BASE_URL` no `dart_defines.json` local (gitignored).
- [x] Manter `GAME_API_BASE_URL` fora de arquivos com segredos versionados.

**Produção atual**

- Worker: `https://guess-the-pokemon.kaique-workspace.workers.dev`
- D1: `guess-the-pokemon` (`ee058ebd-92d3-473e-b81b-2a7b4f7933fd`)
- CORS: `https://pokedex-app-c5e90.web.app`, `https://pokedex-app-c5e90.firebaseapp.com`

## Deploy — concluído

- [x] Aplicar as quatro migrações D1 no ambiente de produção.
- [x] Publicar o Worker (`npm run deploy`).
- [x] Confirmar catálogo com 1.025 Pokémon.
- [x] Verificar migrações aplicadas em ordem.

## Smoke test — concluído

Rodado em produção com `npx tsx scripts/smoke-production.ts`:

- [x] Autenticar usuário de teste pelo Firebase.
- [x] Iniciar partida competitiva.
- [x] Responder corretamente e incorretamente.
- [x] Confirmar que resposta forjada (`optionId` inválido) não altera pontuação.
- [x] Confirmar retry idempotente de publicação.
- [x] Consultar ranking semanal e geral como convidado.
- [x] Confirmar ranking sem expor UID ou e-mail.
- [x] Testar CORS no domínio Web configurado.
- [x] Confirmar limite estável (`GAME_SESSION_CAP` / `RATE_LIMITED`).

## Correção aplicada no deploy

- `rejectBody` agora aceita POST sem payload ou com body vazio (0 bytes),
  para clientes HTTP que enviam stream vazio com `Content-Length: 0`.

## Melhorias futuras

- Adicionar sprites locais em bytes se o modo offline precisar mostrar imagens
  sem depender de cache anterior.
- Reduzir os avisos informativos do `flutter analyze` nos arquivos novos.
- Reavaliar a necessidade de ranking semanal arquivado após uso real.
- Publicar Firebase Hosting (ou outro domínio Web) e validar CORS nesse domínio
  além de `https://pokedata.kaique.site`.

## CI e monitoração — concluído

- [x] Job Worker no CI principal (`validate` + `typecheck` + Vitest + dry-run).
- [x] Deploy automático do Worker em push para `master` (migrações + smoke).
- [x] Teste explícito para `cache-control` / `Vary: Origin`.
- [x] Workflow `free-tier-monitor` (cron 6h) com limiares 70% / 85%.
- [x] CORS de produção inclui `https://pokedata.kaique.site`.
- [x] Observability do Worker habilitada no `wrangler.toml`.
