# Próximos Passos

## Configuração de produção

- Criar o projeto Worker e o banco D1 na conta Cloudflare.
- Configurar o `database_id` real no `wrangler.toml`.
- Configurar `FIREBASE_PROJECT_ID` com o projeto Firebase correto.
- Criar e armazenar `CURSOR_ENCRYPTION_KEY` como secret do Worker.
- Configurar `CORS_ALLOWED_ORIGINS` com os domínios Web reais.
- Configurar `GAME_API_BASE_URL` no `dart_defines.json` apontando para o Worker.
- Manter `GAME_API_BASE_URL` fora de arquivos com segredos versionados.

## Deploy

- Aplicar as migrações D1 no ambiente de produção:

```bash
npx wrangler d1 migrations apply guess-the-pokemon-db --remote
```

- Publicar o Worker:

```bash
npm run deploy
```

- Confirmar que o catálogo contém 1.025 Pokémon antes do deploy.
- Verificar que as quatro migrações estão aplicadas em ordem.

## Smoke test

- Autenticar um usuário de teste pelo Firebase.
- Iniciar uma partida competitiva.
- Responder corretamente e incorretamente.
- Confirmar que uma resposta forjada não altera a pontuação.
- Confirmar retry após falha de publicação.
- Consultar ranking semanal e geral como convidado.
- Confirmar paginação do ranking sem expor UID ou e-mail.
- Testar CORS no domínio Web de produção.
- Confirmar que o rate limit responde com erro estável ao exceder o limite.

## Melhorias futuras

- Adicionar sprites locais em bytes se o modo offline precisar mostrar imagens
  sem depender de cache anterior.
- Adicionar os testes de integração ao CI principal.
- Reduzir os avisos informativos do `flutter analyze` nos arquivos novos.
- Adicionar teste explícito para os headers `cache-control` e `Vary: Origin`.
- Monitorar consumo diário de Workers e D1 para permanecer no tier gratuito.
- Reavaliar a necessidade de ranking semanal arquivado após uso real.
