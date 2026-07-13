import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/legal_document_skeleton.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider);
    final assetPath = legalAssetPath(locale, privacy: true);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePrivacyLabel)),
      body: SafePageBody.belowAppBar(
        child: FutureBuilder<String>(
          future: DefaultAssetBundle.of(context).loadString(assetPath),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(l10n.legalLoadPrivacyError));
            }
            if (!snapshot.hasData) {
              return const LegalDocumentSkeleton();
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: SelectableText(
                snapshot.data!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
