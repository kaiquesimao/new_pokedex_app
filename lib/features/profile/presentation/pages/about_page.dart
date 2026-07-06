import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  static const _kaiqueLinkedInUrl = 'https://www.linkedin.com/in/kaique-simao/';
  static const _juniorLinkedInUrl =
      'https://www.linkedin.com/in/junior-saraiva/';
  static const _figmaDesignUrl =
      'https://www.figma.com/community/file/1202971127473077147';

  static const _credits = <({String title, String body})>[
    (
      title: 'PokéAPI',
      body: 'Dados de Pokémon, espécies, tipos e evoluções.',
    ),
    (
      title: 'Flutter',
      body: 'Framework multiplataforma do app.',
    ),
    (
      title: 'Firebase',
      body: 'Autenticação, favoritos e sincronização em nuvem.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final packageInfo = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: SafePageBody.belowAppBar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 96,
                  height: 96,
                  errorBuilder: (_, _, _) => Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    color: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.catching_pokemon,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PokeData',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              packageInfo.when(
                data: (info) => Text(
                  'Versão ${info.version} (${info.buildNumber})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                loading: () => Text(
                  'Versão …',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                error: (_, _) => Text(
                  'Versão indisponível',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pokedéx feita por fãs para explorar Pokémon, regiões, '
                'favoritos e detalhes com dados atualizados da PokéAPI.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Desenvolvido por',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _AcknowledgmentCard(
                title: 'Kaique Simão',
                body: 'Criador e desenvolvedor do PokeData.',
                links: [
                  (
                    label: 'Perfil no LinkedIn',
                    url: _kaiqueLinkedInUrl,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Agradecimentos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _AcknowledgmentCard(
                title: 'Junior Saraiva',
                body:
                    'Criou o design no Figma Community que serviu de '
                    'referência visual para este projeto.',
                links: [
                  (
                    label: 'Perfil no LinkedIn',
                    url: _juniorLinkedInUrl,
                  ),
                  (
                    label: 'Projeto no Figma',
                    url: _figmaDesignUrl,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Créditos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._credits.map(
                (credit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CreditTile(
                    title: credit.title,
                    body: credit.body,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _DisclaimerCard(theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw StateError('Could not launch $url');
  }
}

class _AcknowledgmentCard extends StatelessWidget {
  const _AcknowledgmentCard({
    required this.title,
    required this.body,
    required this.links,
  });

  final String title;
  final String body;
  final List<({String label, String url})> links;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ...links.map(
              (link) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _openExternalUrl(link.url),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(link.label),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditTile extends StatelessWidget {
  const _CreditTile({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'O PokeData é um aplicativo de fãs, não oficial. '
        'Não é desenvolvido, endossado ou afiliado à Nintendo, '
        'Creatures Inc., GAME FREAK ou The Pokémon Company. '
        'Pokémon © Nintendo / Creatures Inc. / GAME FREAK.',
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }
}
