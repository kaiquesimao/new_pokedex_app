class DisplayNamePolicy {
  DisplayNamePolicy._();

  static const int maxLength = 64;

  static String? validate(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'Informe um nome';
    }
    if (trimmed.length > maxLength) {
      return 'Nome muito longo (máx. $maxLength caracteres)';
    }
    return null;
  }
}
