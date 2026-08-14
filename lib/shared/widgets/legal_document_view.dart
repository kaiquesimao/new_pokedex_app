import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/shared/widgets/legal_document_skeleton.dart';

/// Loads a local legal Markdown asset and renders it with theming.
class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({
    required this.assetPath,
    required this.loadErrorMessage,
    super.key,
  });

  final String assetPath;
  final String loadErrorMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(assetPath),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(loadErrorMessage));
        }
        if (!snapshot.hasData) {
          return const LegalDocumentSkeleton();
        }

        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final bodyStyle = textTheme.bodyMedium?.copyWith(height: 1.6);

        return SingleChildScrollView(
          padding: LegalDocumentSkeleton.contentPadding,
          child: MarkdownBody(
            data: snapshot.data!,
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
      },
    );
  }
}
