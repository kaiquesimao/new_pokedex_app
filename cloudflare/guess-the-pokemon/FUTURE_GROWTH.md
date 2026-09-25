# Melhorias futuras (crescimento do produto)

Backlog opcional para a API/jogo **Guess the Pokémon**.  
Só vale implementar se o produto começar a crescer (mais usuários, mais partidas ou necessidade operacional clara).  
Não bloqueia o uso atual no free tier.

---

## 1. Arquivar ranking semanal antigo

**Por quê:** a tabela/consulta semanal pode crescer sem bound útil; rankings velhos raramente são consultados.

**Ideia:**
- Job periódico (Cron Trigger) ou prune oportunista
- Mover ou agregar semanas fechadas para armazenamento frio / sumário
- Manter só a semana corrente (+ N semanas recentes) quente no D1

**Quando:** volume de `weekly_records` ou custo de leitura começar a incomodar.

---

## 2. Versionamento formal de catálogo (`v2+`)

**Por quê:** hoje o catálogo `v1` é suficiente; mudanças de regras, sprites ou pool de espécies vão exigir coexistência sem quebrar sessões em andamento.

**Ideia:**
- Publicar `catalog-v2.json` (ou equivalente) junto do Worker
- Sessões gravarem `catalogVersion` e responderem só nessa versão
- Migração/documentação de breaking changes entre versões
- Retirar versões antigas só depois de janela de expiração de sessão

**Quando:** precisar alterar dificuldade, pool, sprites ou formato sem derrubar partidas abertas.

---

## 3. Health check (`/health`)

**Por quê:** monitores externos (UptimeRobot, Better Stack, etc.) e load balancers gostam de um endpoint barato e sem auth.

**Ideia:**
- `GET /health` → `200` com `{ "ok": true }` (e opcionalmente checagem leve de D1)
- Sem PII, sem auth, sem side effects caros
- Não contar no rate limit de jogo

**Quando:** quiser alerta automático se o Worker cair ou o deploy falhar em silêncio.

---

## 4. Métricas de negócio (partidas/dia, etc.)

**Por quê:** Observability do Worker mostra saúde técnica; não substitui produto (engajamento, retenção, abuso).

**Ideia (leve, free-tier friendly):**
- Contadores diários em D1 (sessions started, answers, publishes, unique users)
- Ou Analytics Engine / logs estruturados agregados offline
- Dashboard simples (script + planilha ou página interna)

**Quando:** precisar decidir pricing, limites, ou se o jogo “está sendo jogado”.

---

## Fora de escopo deste backlog

Itens que **não** entram aqui de propósito:

- Mais framework / Zod / Clean Architecture / ORM
- Cache Redis/KV “por padrão” sem evidência de gargalo
- Deploy do Hono e smoke pós-merge (isso é operação imediata, não crescimento)

Melhorias menores já anotadas em `NEXT_STEPS.md` (sprites offline, avisos do Flutter analyze, domínio Web/CORS) continuam lá.
