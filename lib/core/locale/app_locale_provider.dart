import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';

final appLocaleProvider = Provider<AppLocale>((ref) {
  final settings = ref.watch(profileSettingsProvider);
  return AppLocale.fromTag(settings.appLanguage);
});
