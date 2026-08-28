import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/features/legal/presentation/providers/legal_document_provider.dart';
import 'package:pokedex_app/shared/widgets/legal_document_skeleton.dart';

/// Loads a legal Markdown document (Firestore with cache/asset fallback).
class const LegalDocumentView({
  required final LegalDocument document,
  required final String loadErrorMessage,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final content = ref.watch(
      legalDocumentProvider((document: document, locale: locale)),
    );

    return content.when(
      loading: () => const LegalDocumentSkeleton(),
      error: (_, _) => Center(child: Text(loadErrorMessage)),
      data: (documentContent) => _LegalMarkdownBody(
        markdown: documentContent.markdown,
      ),
    );
  }
}

class const _LegalMarkdownBody({
  required final String markdown,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bodyStyle = textTheme.bodyMedium?.copyWith(height: 1.6);

    return SingleChildScrollView(
      padding: LegalDocumentSkeleton.contentPadding,
      child: MarkdownBody(
        data: markdown,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: bodyStyle,
          h1: textTheme.headlineMedium,
          h2: textTheme.titleLarge,
          h3: textTheme.titleMedium,
          h4: textTheme.titleSmall,
          strong: bodyStyle?.copyWith(fontWeight: FontWeight.w700),
          em: bodyStyle?.copyWith(fontStyle: FontStyle.italic),
          a: bodyStyle?.copyWith(color: theme.colorScheme.primary),
          listBullet: bodyStyle,
        ),
      ),
    );
  }
}
