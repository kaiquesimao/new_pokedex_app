import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/auth_hub_action_frame.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:pokedex_app/features/profile/presentation/widgets/delete_account_bottom_sheet.dart';
import 'package:pokedex_app/features/profile/presentation/widgets/logout_bottom_sheet.dart';
import 'package:pokedex_app/features/reviews/presentation/providers/app_review_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class const ProfilePage({super.key}) extends ConsumerStatefulWidget {
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
              onRateTap: () => _handleRateApp(context, ref),
              onHelpTap: () => context.push('/profile/help'),
              onAboutTap: () => context.push('/profile/about'),
            ),
            if (auth.isAuthenticated) ...[
              const SizedBox(height: 32),
              _LogoutSection(
                displayName: auth.displayName ?? l10n.authDefaultTrainerName,
                onLogout: () => _handleLogout(context, ref),
                onDeleteAccount: () => _handleDeleteAccount(context, ref),
                onAccountDeletionInfo: () =>
                    context.push('/legal/account-deletion'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _handleRateApp(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref.read(appReviewControllerProvider).rateFromSettings();
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).profileRateAppError,
          ),
        ),
      );
    }
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

  static Future<void> _handleDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final auth = ref.read(authProvider);
    final result = await showDeleteAccountBottomSheet(
      context,
      requirePassword: auth.canEditCredentials,
    );
    if (result == null || !context.mounted) return;

    try {
      await ref
          .read(authProvider.notifier)
          .deleteAccount(
            currentPassword: result.password,
            clearUserData: () =>
                ref.read(favoritesRepositoryProvider).clearAll(),
          );
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).profileDeleteAccountError,
            ),
          ),
        );
      }
      return;
    }

    if (context.mounted) context.go('/welcome');
  }
}

class const _GuestAccountSection({
  required final VoidCallback onLogin,
  required final VoidCallback onRegister,
}) extends StatelessWidget {
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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

class const _AccountSection({
  required final String name,
  required final String email,
  required final bool canEditCredentials,
  final VoidCallback? onEditName,
  final VoidCallback? onEditEmail,
  final VoidCallback? onChangePassword,
}) extends StatelessWidget {
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

class const _SettingsSections({
  required final ProfileSettings settings,
  required final String versionLabel,
  required final ValueChanged<bool> onToggleNotifyNew,
  required final ValueChanged<bool> onToggleNotifyUpdates,
  required final VoidCallback onToggleAppLanguage,
  required final VoidCallback onTermsTap,
  required final VoidCallback onPrivacyTap,
  required final VoidCallback onRateTap,
  required final VoidCallback onHelpTap,
  required final VoidCallback onAboutTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            if (!kIsWeb)
              _ChevronRow(
                label: l10n.profileRateAppLabel,
                onTap: onRateTap,
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

class const _SettingsGroup({
  required final String title,
  required final List<Widget> children,
}) extends StatelessWidget {
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

class const _ToggleRow({
  required final String label,
  required final bool value,
  required final ValueChanged<bool> onChanged,
}) extends StatelessWidget {
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

class const _ChevronRow({
  required final String label,
  final String? value,
  final VoidCallback? onTap,
  final bool showChevron = true,
}) extends StatelessWidget {
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

class const _LogoutSection({
  required final String displayName,
  required final VoidCallback onLogout,
  required final VoidCallback onDeleteAccount,
  required final VoidCallback onAccountDeletionInfo,
}) extends StatelessWidget {
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
        const SizedBox(height: 12),
        TextButton(
          onPressed: onDeleteAccount,
          style: TextButton.styleFrom(foregroundColor: logoutRed),
          child: Text(l10n.profileDeleteAccountButton),
        ),
        TextButton(
          onPressed: onAccountDeletionInfo,
          child: Text(l10n.profileAccountDeletionLink),
        ),
      ],
    );
  }
}
