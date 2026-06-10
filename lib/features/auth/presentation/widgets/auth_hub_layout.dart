import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class AuthHubLayout extends StatelessWidget {
  const AuthHubLayout({
    super.key,
    required this.appBarTitle,
    required this.headline,
    required this.subtitle,
    required this.actions,
    this.illustrationAsset = AppAssets.trainerAsh,
    this.footer,
    this.showBackButton = true,
  });

  final String appBarTitle;
  final String headline;
  final String subtitle;
  final List<Widget> actions;
  final String illustrationAsset;
  final Widget? footer;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.chevron_left, size: 28),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/login'),
              )
            : null,
        title: Text(
          appBarTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafePageBody.belowAppBar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Image.asset(
                  illustrationAsset,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.catching_pokemon,
                    size: 100,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                headline,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ...actions
                  .expand((action) => [action, const SizedBox(height: 12)])
                  .toList()
                ..removeLast(),
              if (footer != null) ...[const SizedBox(height: 20), footer!],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

void showSocialAuthStubSnackBar(BuildContext context, String provider) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('Login com $provider em breve')));
}
