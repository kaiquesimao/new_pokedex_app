# PokeData

Uma Pokédex moderna para fãs — explore Pokémon, regiões e detalhes; sincronize favoritos entre dispositivos; jogue **Guess the Pokémon**.

Feito com **Flutter** para **Android** e **Web** (mobile-first). Publicado na Google Play e na web.

**English:** [README.md](README.md)

| | |
|---|---|
| **Google Play** | [Pokedata: Pokedex](https://play.google.com/store/apps/details?id=com.kaiquesimao.pokedex) |
| **Web** | [https://pokedata.kaique.site](https://pokedata.kaique.site) |
| **Package** | `com.kaiquesimao.pokedex` |

---

## Visão geral

PokeData é um app de referência feito por fã, focado no uso do dia a dia: busca rápida, telas de detalhe legíveis e navegação discreta. Visitantes exploram a Pokédex completa sem conta; o login libera favoritos sincronizados e o modo competitivo do jogo.

O produto foi desenhado para custo zero de infraestrutura: cliente, autenticação, sync, hosting estático e API do jogo rodam em serviços de **free tier**, e várias decisões de engenharia existem por causa desses limites.

---

## Superfície do produto

- **Pokédex** — lista completa com número da National Dex, sprites e tipos; busca; filtros por tipo e geração
- **Perfis de detalhe** — stats, habilidades, altura/peso, fraquezas, evolução, flavor text localizado, cries, variantes de sprite
- **Regiões** — Pokémon por região
- **Favoritos** — coração para salvar; exige conta; sync via Firestore
- **Modo convidado** — navegação completa sem login; auth só quando necessário
- **Cache offline-friendly** — dados já carregados seguem disponíveis sem rede
- **Localização** — português e inglês (UI + textos da PokéAPI quando existem)
- **Guess the Pokémon** — jogo de silhueta/quiz com modo local e modo competitivo autenticado (ranking, publicação de score)
- **Conta e legal** — perfil, fluxos de senha/e-mail, termos/privacidade, exclusão de conta (Data Safety da Play)

---

## Arquitetura

O app usa organização **feature-first** com limites claros inspirados em clean architecture.

```text
lib/
  core/          # bootstrap, router, network, Drift DB, Firebase, locale, theme
  features/      # auth, pokemon, regions, favorites, guess_the_pokemon, …
    <feature>/
      domain/        # entidades, contratos de repositório, políticas
      data/          # datasources, mappers, implementações
      presentation/  # pages, widgets, providers/controllers Riverpod
  shared/        # UI reutilizável
  l10n/          # ARB + localizations geradas
```

**Estado e navegação:** Riverpod para DI e estado de UI; `go_router` para rotas, redirects de auth e shell.

### Fluxo de dados da Pokédex

```text
UI (Riverpod)
    → PokemonRepository
        → Remote (PokéAPI via Dio)
        → Cache local (Drift)
    → entities → presentation
```

Respostas remotas viram entidades de domínio e são persistidas localmente para lista/detalhe responsivos e degradação offline. Mudança de locale reconstrói índices de nome e caches de texto de jogo.

### Auth e favoritos

| Concern | Abordagem |
|---------|-----------|
| Identidade | Firebase Authentication |
| E-mail/senha | Todas as plataformas (web + mobile) |
| Google Sign-In | **Somente mobile** (ver [Decisões](#decisões-de-design--tradeoffs)) |
| Convidado | Permitido na Pokédex/regiões; sem favoritos persistidos |
| Favoritos | `users/{uid}/favorites/{pokemonId}` no Cloud Firestore após login |

Builds de release exigem Firebase. Em debug, pode haver fallback local de auth para desenvolvimento.

### Guess the Pokémon

Dois modos no mesmo módulo de feature:

| Modo | Comportamento |
|------|----------------|
| **Local** | Catálogo embutido (`assets/game/catalog-v1.json`); scores no dispositivo |
| **Competitivo** | Cloudflare Worker + D1; Firebase ID token nas mutações; ranking e publish |

O Worker serve o gameplay a partir de um **catálogo versionado no repositório** (validado no build). **Não** chama PokéAPI em tempo de request — essencial para orçamento free tier e sessões determinísticas. Rate limits por usuário e IP (inícios de sessão, respostas, publishes).

```text
Cliente Flutter
    → catálogo local / melhor score (SharedPreferences + assets)
    → GAME_API_BASE_URL opcional
        → Worker (/v1/game, /v1/leaderboards, /v1/me/…)
            → D1 (sessões, scores, buckets de rate limit)
            → verificação de token Firebase
```

### Topologia de hosting (visão geral)

| Peça | Papel |
|------|--------|
| Flutter Android | Distribuição na Play Store |
| Flutter Web (Wasm + fallback JS) | Cloudflare Pages (`pokedata.kaique.site`) |
| Firebase Auth + Firestore | Identidade, favoritos, documentos legais |
| Cloudflare Worker + D1 | API do jogo competitivo |
| GitHub Actions | Analyze, test, deploy web/Worker, upload de AAB, monitor free tier |

---

## Stack

| Camada | Escolha |
|--------|---------|
| Cliente | Flutter 3.47+ / Dart 3.13+, Material, Poppins |
| Estado | Riverpod 3 |
| Rotas | go_router |
| DB local | Drift |
| HTTP | Dio (+ guards offline/retry) |
| Auth / sync | Firebase Auth, Cloud Firestore |
| Analytics | Firebase Analytics |
| API do jogo | Cloudflare Workers, D1 |
| Runtime web | Wasm (skwasm multi-thread) com fallback JS |
| CI | GitHub Actions |
| Qualidade | `very_good_analysis`, suite ampla de testes |

---

## Decisões de design & tradeoffs

### WebAssembly multi-thread vs Google Sign-In na web

A web de produção ativa **isolamento cross-origin** (COOP / COEP) para o renderer Wasm usar **SharedArrayBuffer** e skwasm multi-thread. Esse isolamento é incompatível com os helpers de Google Auth do Firebase no browser.

**Decisão:** manter Wasm multi-thread pela performance na web; oferecer **e-mail/senha** na web; manter **Google Sign-In no Android** (e Sign in with Apple onde couber no mobile). Mesmo produto, superfície de auth adequada a cada plataforma — não é feature “pela metade”.

### Free tier de propósito

A stack foi escolhida para um produto publicado real rodar a **US$ 0** de infra:

- Firebase Spark (Auth + Firestore para favoritos/legal)
- Cloudflare Pages (Flutter web estático)
- Workers + D1 (API do jogo dentro dos tetos diários free)
- GitHub Actions para CI/CD

**Consequências:** rate limits conservadores no Worker; catálogo embutido no Worker; job agendado que alerta/falha quando o uso de Workers/D1 se aproxima do teto; modo competitivo opcional (cliente joga local se a URL da API não estiver definida).

### Pokédex guest-first; conta para persistência

Explorar não pode ter atrito. Favoritos e identidade competitiva precisam de `uid` estável, então esses fluxos pedem login (com prompt claro, sem muro na abertura).

### Dados de Pokémon com cache primeiro

PokéAPI é a fonte da verdade; Drift é a camada de offline e performance. Tradeoff: entradas em cache podem ficar defasadas até o refresh — aceitável para um app de referência e melhor em redes instáveis.

### Dois modos de jogo em uma feature

O modo local valida a UX sem backend. O competitivo adiciona fairness (sessões no servidor), ranking e caps anti-abuso. Tipos de domínio compartilhados mantêm a UI consistente.

### Android primeiro; iOS depois

O alvo de produção atual é Android (Play Store) + Web. **iOS é plataforma futura planejada**, não descartada — o código Flutter é a base dessa expansão.

---

## Restrições e limitações conhecidas

- **Google Sign-In não está disponível na web** enquanto o Wasm multi-thread (COOP/COEP) permanecer ativo
- **Layout mobile-first** — viewports desktop largos esticam alguns layouts de detalhe; a melhor experiência é viewport de celular ou o app Android
- **iOS** — ainda não está no track de release de produção (item de roadmap)
- **Projeto fan-made** — dados da PokéAPI podem mudar conforme o upstream
- Tetos de free tier exigem atenção contínua (monitor + rate limits); crescimento pode exigir plano pago ou mais otimizações

---

## Pontos fortes de engenharia

- **Produto publicado** — ao vivo na [Google Play](https://play.google.com/store/apps/details?id=com.kaiquesimao.pokedex) e na [web](https://pokedata.kaique.site)
- **Arquitetura modular clara** — features isoladas com contratos de domínio e camadas data/presentation testáveis
- **Testes automatizados amplos** — domínio, repositórios, providers e widgets (auth, Pokédex, jogo, networking)
- **Wasm web em produção** — renderer multi-thread com fallback JS
- **CI/CD** — analyze + test em todo push/PR; deploy web/Worker a partir de `master`; upload de AAB assinado para open testing da Play em bumps de versão
- **Disciplina de free tier** — monitor de uso Workers/D1; API do jogo sem martelar PokéAPI em runtime
- **Compliance Play** — docs legais no app, URL de exclusão de conta para Data Safety, hooks de in-app review
- **i18n** — strings PT/EN e resolução de textos localizados da PokéAPI

---

## Roadmap

- Track de release **iOS** (paridade de auth e requisitos de store com Android)
- Melhorias contínuas de QoL no jogo e na Pokédex dentro dos limites de free tier

---

## Aviso legal

PokeData é um projeto **fan-made**. Não é desenvolvido, endossado ou afiliado à Nintendo, The Pokémon Company, Game Freak ou Creatures Inc. Pokémon e nomes de personagens Pokémon são marcas de seus respectivos proprietários. Dados de espécies vêm da [PokéAPI](https://pokeapi.co/).
