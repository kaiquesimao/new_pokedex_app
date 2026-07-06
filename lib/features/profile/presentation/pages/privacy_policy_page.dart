import 'package:flutter/material.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de privacidade')),
      body: SafePageBody.belowAppBar(
        child: FutureBuilder<String>(
          future: DefaultAssetBundle.of(
            context,
          ).loadString('assets/legal/privacy_pt_br.md'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Não foi possível carregar a política de privacidade.',
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
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
