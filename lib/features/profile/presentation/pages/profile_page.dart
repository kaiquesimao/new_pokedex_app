import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_action_frame.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:pokedex_app/features/profile/presentation/widgets/logout_bottom_sheet.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(authProvider.notifier).refreshAuthenticatedUser();
      } on Object {
        // ponytail: best-effort sync when opening profile
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final settings = ref.watch(profileSettingsProvider);
    final packageInfo = ref.watch(packageInfoProvider);
    final l10n = AppLocalizations.of(context);

    final versionLabel = packageInfo.when(
      data: (info) => '${info.version} (${info.buildNumber})',
      loading: () => l10n.aboutVersionLoading,
      error: (_, _) => l10n.aboutVersionUnavailable,
    );

    return Scaffold(
      body: SafePageBody(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            AppBottomNavBar.overlayHeight(context),
          ),
          children: [
            if (auth.isAuthenticated) ...[
              _AccountSection(
                name: auth.displayName ?? l10n.authDefaultTrainerName,
                email: auth.email ?? '',
                canEditCredentials: auth.canEditCredentials,
                onEditName: auth.canEditCredentials
                    ? () => context.push('/profile/edit-name')
                    : null,
                onEditEmail: auth.canEditCredentials
                    ? () => context.push('/profile/change-email')
                    : null,
                onChangePassword: auth.canEditCredentials
                    ? () => context.push('/profile/change-password')
                    : null,
              ),
            ] else ...[
              _GuestAccountSection(
                onLogin: () => context.push('/login'),
                onRegister: () => context.push('/register'),
              ),
            ],
            const SizedBox(height: 24),
            _SettingsSections(
              settings: settings,
              versionLabel: versionLabel,
              onToggleMega: (value) => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .setShowMegaEvolutions(value: value),
              ),
              onToggleOtherForms: (value) => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .setShowOtherForms(value: value),
              ),
              onToggleNotifyNew: (value) => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .setNotifyNewPokemon(value: value),
              ),
              onToggleNotifyUpdates: (value) => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .setNotifyAppUpdates(value: value),
              ),
              onToggleAppLanguage: () => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .toggleAppLanguage(),
              ),
              onTermsTap: () => context.push('/legal/terms'),
              onPrivacyTap: () => context.push('/legal/privacy'),
              onHelpTap: () => context.push('/profile/help'),
              onAboutTap: () => context.push('/profile/about'),
            ),
            if (auth.isAuthenticated) ...[
              const SizedBox(height: 32),
              _LogoutSection(
                displayName: auth.displayName ?? l10n.authDefaultTrainerName,
                onLogout: () => _handleLogout(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _saveSetting(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    await action();
    if (context.mounted) showProfileSuccessSnackbar(context);
  }

  static void showProfileSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).profileActionSuccess),
        backgroundColor: AppColorsLight.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showLogoutBottomSheet(context);
    if (confirmed != true || !context.mounted) return;

    await ref.read(authProvider.notifier).signOut();
    if (context.mounted) {
      context.go('/welcome');
    }
  }
}

class _GuestAccountSection extends StatelessWidget {
  const _GuestAccountSection({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return _SettingsGroup(
      title: l10n.navAccount,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.authLoginRequiredDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              AuthHubActionFrame(
                child: AppButton(
                  label: l10n.authLoginButtonLabel,
                  onPressed: onLogin,
                ),
              ),
              const SizedBox(height: 12),
              AuthHubActionFrame(
                child: AppButton(
                  label: l10n.authWelcomeCreateAccount,
                  variant: AppButtonVariant.outline,
                  onPressed: onRegister,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.name,
    required this.email,
    required this.canEditCredentials,
    this.onEditName,
    this.onEditEmail,
    this.onChangePassword,
  });

  final String name;
  final String email;
  final bool canEditCredentials;
  final VoidCallback? onEditName;
  final VoidCallback? onEditEmail;
  final VoidCallback? onChangePassword;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SettingsGroup(
      title: l10n.navAccount,
      children: [
        _ChevronRow(
          label: l10n.authNameLabel,
          value: name,
          onTap: onEditName,
          showChevron: canEditCredentials,
        ),
        _ChevronRow(
          label: l10n.authEmailLabel,
          value: email,
          onTap: onEditEmail,
          showChevron: canEditCredentials,
        ),
        if (canEditCredentials)
          _ChevronRow(
            label: l10n.authPasswordLabel,
            value: '••••••••',
            onTap: onChangePassword,
          ),
      ],
    );
  }
}

class _SettingsSections extends StatelessWidget {
  const _SettingsSections({
    required this.settings,
    required this.versionLabel,
    required this.onToggleMega,
    required this.onToggleOtherForms,
    required this.onToggleNotifyNew,
    required this.onToggleNotifyUpdates,
    required this.onToggleAppLanguage,
    required this.onTermsTap,
    required this.onPrivacyTap,
    required this.onHelpTap,
    required this.onAboutTap,
  });

  final ProfileSettings settings;
  final String versionLabel;
  final ValueChanged<bool> onToggleMega;
  final ValueChanged<bool> onToggleOtherForms;
  final ValueChanged<bool> onToggleNotifyNew;
  final ValueChanged<bool> onToggleNotifyUpdates;
  final VoidCallback onToggleAppLanguage;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onHelpTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsGroup(
          title: l10n.navPokedex,
          children: [
            _ToggleRow(
              label: l10n.profileMegaEvolutionsLabel,
              value: settings.showMegaEvolutions,
              onChanged: onToggleMega,
            ),
            _ToggleRow(
              label: l10n.profileOtherFormsLabel,
              value: settings.showOtherForms,
              onChanged: onToggleOtherForms,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsGroup(
          title: l10n.profileNotificationsTitle,
          children: [
            _ToggleRow(
              label: l10n.profileNotifyNewPokemon,
              value: settings.notifyNewPokemon,
              onChanged: onToggleNotifyNew,
            ),
            _ToggleRow(
              label: l10n.profileNotifyAppUpdates,
              value: settings.notifyAppUpdates,
              onChanged: onToggleNotifyUpdates,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsGroup(
          title: l10n.profileLanguageTitle,
          children: [
            _ChevronRow(
              label: l10n.profileAppLanguageLabel,
              value: settings.appLanguageLabel,
              onTap: onToggleAppLanguage,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsGroup(
          title: l10n.profileGeneralTitle,
          children: [
            _ChevronRow(
              label: l10n.profileVersionLabel,
              value: versionLabel,
              showChevron: false,
            ),
            _ChevronRow(
              label: l10n.profileTermsLabel,
              onTap: onTermsTap,
            ),
            _ChevronRow(
              label: l10n.profilePrivacyLabel,
              onTap: onPrivacyTap,
            ),
            _ChevronRow(
              label: l10n.profileHelpLabel,
              onTap: onHelpTap,
            ),
            _ChevronRow(
              label: l10n.profileAboutLabel,
              onTap: onAboutTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
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
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _ChevronRow extends StatelessWidget {
  const _ChevronRow({
    required this.label,
    this.value,
    this.onTap,
    this.showChevron = true,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          if (showChevron) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _LogoutSection extends StatelessWidget {
  const _LogoutSection({required this.displayName, required this.onLogout});

  final String displayName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    const logoutRed = Color(0xFFE3350D);

    return Column(
      children: [
        Text(
          l10n.profileLoggedInAs(displayName),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        AuthHubNarrowFrame(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: logoutRed,
                side: const BorderSide(color: logoutRed, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.profileLogoutButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
