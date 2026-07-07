import 'package:flutter/material.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const supportEmail = 'pokedata.app@gmail.com';

  static const _faqItems = <({String question, String answer})>[
    (
      question: 'Como explorar sem criar conta?',
      answer:
          'Na tela de boas-vindas, toque em "Explorar sem conta" para '
          'navegar pelo Pokédex, regiões e detalhes dos Pokémon sem '
          'precisar fazer login.',
    ),
    (
      question: 'Como favoritar Pokémon?',
      answer:
          'Toque no ícone de coração na lista ou na página de detalhes. '
          'É necessário entrar na sua conta para salvar e sincronizar '
          'favoritos entre dispositivos.',
    ),
    (
      question: 'Como filtrar a lista de Pokémon?',
      answer:
          'Na aba Pokédex, use a barra de busca e os filtros por tipo e '
          'geração para refinar os resultados exibidos.',
    ),
    (
      question: 'Como alterar o idioma?',
      answer:
          'Em Conta → Idioma, alterne "Interface do app" e '
          '"Informações do jogo" entre português e inglês.',
    ),
    (
      question: 'O que são mega evoluções e outras formas?',
      answer:
          'Em Conta → PokeData, use os interruptores para exibir ou '
          'ocultar mega evoluções e formas alternativas na lista.',
    ),
    (
      question: 'O app funciona offline?',
      answer:
          'Dados visitados recentemente podem aparecer a partir do cache '
          'local. Para buscar novos Pokémon ou atualizar informações, '
          'é necessária conexão com a internet.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda')),
      body: SafePageBody.belowAppBar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Perguntas frequentes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < _faqItems.length; i++) ...[
                      _FaqTile(item: _faqItems[i]),
                      if (i < _faqItems.length - 1)
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.dividerColor,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Suporte',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Não encontrou o que procura? Envie sua dúvida ou '
                        'relato de problema para nossa equipe.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _openSupportEmail(context),
                        icon: const Icon(Icons.mail_outline, size: 20),
                        label: const Text(HelpPage.supportEmail),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openSupportEmail(BuildContext context) async {
  final uri = Uri(
    scheme: 'mailto',
    path: HelpPage.supportEmail,
    query: 'subject=${Uri.encodeComponent('Suporte PokeData')}',
  );

  if (!await launchUrl(uri)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível abrir o aplicativo de e-mail.'),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final ({String question, String answer}) item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          item.question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
