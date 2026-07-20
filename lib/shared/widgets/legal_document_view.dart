import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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
        final bodyStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.6);

        return SingleChildScrollView(
          padding: LegalDocumentSkeleton.contentPadding,
          child: MarkdownBody(
            data: snapshot.data!,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: bodyStyle,
            ),
          ),
        );
      },
    );
  }
}
