/// Shared breakpoints and widths for adaptive layouts.
abstract final class ResponsiveLayout {
  /// Tablet-width column for web/desktop; keeps UI from stretching on wide screens.
  static const double maxContentWidth = 768;

  static const double wideBreakpoint = maxContentWidth;
}
