import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:pokedex_app/features/profile/presentation/widgets/logout_bottom_sheet.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final settings = ref.watch(profileSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Conta')),
      body: SafePageBody.inTabShell(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (auth.isAuthenticated) ...[
              _AccountSection(
                name: auth.displayName ?? 'Treinador',
                email: auth.email ?? '',
                onEditName: () => _showPlaceholderEdit(context, 'Nome'),
                onEditEmail: () => _showPlaceholderEdit(context, 'E-mail'),
                onChangePassword: () =>
                    context.push('/profile/change-password'),
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
              onToggleMega: (value) => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .setShowMegaEvolutions(value),
              ),
              onToggleOtherForms: (value) => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .setShowOtherForms(value),
              ),
              onToggleNotifyNew: (value) => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .setNotifyNewPokemon(value),
              ),
              onToggleNotifyUpdates: (value) => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .setNotifyAppUpdates(value),
              ),
              onToggleInterfaceLanguage: () => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .toggleInterfaceLanguage(),
              ),
              onToggleGameInfoLanguage: () => _saveSetting(
                context,
                ref,
                () => ref
                    .read(profileSettingsProvider.notifier)
                    .toggleGameInfoLanguage(),
              ),
              onPlaceholderLink: (label) =>
                  _showPlaceholderLink(context, label),
            ),
            if (auth.isAuthenticated) ...[
              const SizedBox(height: 32),
              _LogoutSection(
                displayName: auth.displayName ?? 'Treinador',
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
      const SnackBar(
        content: Text('Ação realizada com sucesso'),
        backgroundColor: AppColorsLight.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void _showPlaceholderEdit(BuildContext context, String field) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edição de $field em breve')));
  }

  static void _showPlaceholderLink(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — em breve')));
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

    return _SettingsGroup(
      title: 'Conta',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Entre na sua conta para sincronizar favoritos e gerenciar seus dados.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              AppButton(label: 'Entrar', onPressed: onLogin),
              const SizedBox(height: 12),
              AppButton(
                label: 'Criar conta',
                variant: AppButtonVariant.outline,
                onPressed: onRegister,
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
    required this.onEditName,
    required this.onEditEmail,
    required this.onChangePassword,
  });

  final String name;
  final String email;
  final VoidCallback onEditName;
  final VoidCallback onEditEmail;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return _SettingsGroup(
      title: 'Conta',
      children: [
        _ChevronRow(label: 'Nome', value: name, onTap: onEditName),
        _ChevronRow(label: 'E-mail', value: email, onTap: onEditEmail),
        _ChevronRow(label: 'Senha', value: '••••••••', onTap: onChangePassword),
      ],
    );
  }
}

class _SettingsSections extends StatelessWidget {
  const _SettingsSections({
    required this.settings,
    required this.onToggleMega,
    required this.onToggleOtherForms,
    required this.onToggleNotifyNew,
    required this.onToggleNotifyUpdates,
    required this.onToggleInterfaceLanguage,
    required this.onToggleGameInfoLanguage,
    required this.onPlaceholderLink,
  });

  final ProfileSettings settings;
  final ValueChanged<bool> onToggleMega;
  final ValueChanged<bool> onToggleOtherForms;
  final ValueChanged<bool> onToggleNotifyNew;
  final ValueChanged<bool> onToggleNotifyUpdates;
  final VoidCallback onToggleInterfaceLanguage;
  final VoidCallback onToggleGameInfoLanguage;
  final ValueChanged<String> onPlaceholderLink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsGroup(
          title: 'Pokédex',
          children: [
            _ToggleRow(
              label: 'Mega evoluções',
              value: settings.showMegaEvolutions,
              onChanged: onToggleMega,
            ),
            _ToggleRow(
              label: 'Outras formas',
              value: settings.showOtherForms,
              onChanged: onToggleOtherForms,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsGroup(
          title: 'Notificações',
          children: [
            _ToggleRow(
              label: 'Novos Pokémon',
              value: settings.notifyNewPokemon,
              onChanged: onToggleNotifyNew,
            ),
            _ToggleRow(
              label: 'Atualizações do app',
              value: settings.notifyAppUpdates,
              onChanged: onToggleNotifyUpdates,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsGroup(
          title: 'Idioma',
          children: [
            _ChevronRow(
              label: 'Interface do app',
              value: settings.interfaceLanguageLabel,
              onTap: onToggleInterfaceLanguage,
            ),
            _ChevronRow(
              label: 'Informações do jogo',
              value: settings.gameInfoLanguageLabel,
              onTap: onToggleGameInfoLanguage,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsGroup(
          title: 'Geral',
          children: [
            _ChevronRow(
              label: 'Versão',
              value: ProfileSettings.appVersion,
              showChevron: false,
            ),
            _ChevronRow(
              label: 'Termos de uso',
              onTap: () => onPlaceholderLink('Termos de uso'),
            ),
            _ChevronRow(
              label: 'Ajuda',
              onTap: () => onPlaceholderLink('Ajuda'),
            ),
            _ChevronRow(
              label: 'Sobre',
              onTap: () => onPlaceholderLink('Sobre'),
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
    const logoutRed = Color(0xFFE3350D);

    return Column(
      children: [
        Text(
          'Você entrou como $displayName',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SizedBox(
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
            child: const Text(
              'Sair',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
