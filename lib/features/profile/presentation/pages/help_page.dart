import 'package:flutter/material.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const supportEmail = 'pokedata.app@gmail.com';

  static List<({String question, String answer})> _faqItems(
    AppLocalizations l10n,
  ) => [
    (
      question: l10n.helpExploreGuestQuestion,
      answer: l10n.helpExploreGuestAnswer,
    ),
    (
      question: l10n.helpFavoriteQuestion,
      answer: l10n.helpFavoriteAnswer,
    ),
    (
      question: l10n.helpFilterQuestion,
      answer: l10n.helpFilterAnswer,
    ),
    (
      question: l10n.profileHelpLanguageQuestion,
      answer: l10n.profileHelpLanguageAnswer,
    ),
    (
      question: l10n.helpMegaFormsQuestion,
      answer: l10n.helpMegaFormsAnswer,
    ),
    (
      question: l10n.helpOfflineQuestion,
      answer: l10n.helpOfflineAnswer,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final faqItems = _faqItems(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileHelpLabel)),
      body: SafePageBody.belowAppBar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.helpFaqTitle,
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
                    for (var i = 0; i < faqItems.length; i++) ...[
                      _FaqTile(item: faqItems[i]),
                      if (i < faqItems.length - 1)
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
                l10n.helpSupportTitle,
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
                        l10n.helpSupportBody,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _openSupportEmail(context, l10n),
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

Future<void> _openSupportEmail(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final uri = Uri(
    scheme: 'mailto',
    path: HelpPage.supportEmail,
    query: 'subject=${Uri.encodeComponent(l10n.helpEmailSubject)}',
  );

  if (!await launchUrl(uri)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.helpEmailOpenError)),
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
