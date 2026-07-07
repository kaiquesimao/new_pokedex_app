import 'package:pokedex_app/core/locale/app_locale.dart';

String legalAssetPath(AppLocale locale, {required bool privacy}) {
  final lang = locale == AppLocale.pt ? 'pt_br' : 'en';
  final name = privacy ? 'privacy' : 'terms';
  return 'assets/legal/${name}_$lang.md';
}
