/// Picks localized strings from PokeAPI `names` / `flavor_text_entries` arrays.
abstract final class PokeApiLocalizedText {
  /// Fallback order: [preferredLang] → `en` → first available → [fallback].
  static String? pickName(
    List<dynamic> entries,
    String preferredLang, {
    String? fallback,
  }) {
    return _pickText(entries, preferredLang, 'name') ?? fallback;
  }

  /// Same language priority as [pickName]; normalizes `\n` and `\f` to spaces.
  static String? pickFlavorText(
    List<dynamic> entries,
    String preferredLang,
  ) {
    final text = _pickText(entries, preferredLang, 'flavor_text');
    if (text == null) return null;
    return text.replaceAll('\n', ' ').replaceAll('\f', ' ');
  }

  static bool hasEntry(
    List<dynamic> entries,
    String lang,
    String textKey,
  ) {
    return _findEntryText(entries, lang, textKey) != null;
  }

  static String? pickOfficial(
    List<dynamic> entries,
    String lang,
    String textKey,
  ) {
    if (!hasEntry(entries, lang, textKey)) return null;
    return _findEntryText(entries, lang, textKey);
  }

  static String? pickEnglish(List<dynamic> entries, String textKey) {
    return _findEntryText(entries, 'en', textKey);
  }

  static String? _pickText(
    List<dynamic> entries,
    String preferredLang,
    String textKey,
  ) {
    final preferred = _findEntryText(entries, preferredLang, textKey);
    if (preferred != null) return preferred;

    final en = _findEntryText(entries, 'en', textKey);
    if (en != null) return en;

    for (final entry in entries) {
      final text = _entryText(entry, textKey);
      if (text != null && text.isNotEmpty) return text;
    }

    return null;
  }

  static String? _findEntryText(
    List<dynamic> entries,
    String lang,
    String textKey,
  ) {
    for (final entry in entries) {
      if (_entryLang(entry) != lang) continue;
      final text = _entryText(entry, textKey);
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _entryLang(dynamic entry) {
    final map = entry as Map<String, dynamic>;
    final language = map['language'] as Map<String, dynamic>? ?? {};
    return language['name'] as String?;
  }

  static String? _entryText(dynamic entry, String textKey) {
    final map = entry as Map<String, dynamic>;
    return map[textKey] as String?;
  }
}
