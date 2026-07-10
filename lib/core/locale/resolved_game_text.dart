import 'package:pokedex_app/core/locale/game_text_source.dart';

class ResolvedGameText {
  const ResolvedGameText({required this.text, required this.source});

  final String text;
  final GameTextSource source;
}
