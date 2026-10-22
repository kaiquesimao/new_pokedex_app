import 'package:shared_preferences/shared_preferences.dart';

const whatsNewLastSeenVersionCodeKey = 'whats_new_last_seen_version_code';

enum WhatsNewOutcome {
  /// Open the sheet for this versionCode.
  show,

  /// Store the current versionCode without UI (first session or no notes).
  recordSilently,

  /// This versionCode was already handled.
  ignore,
}

int? readWhatsNewLastSeenVersionCode(SharedPreferences prefs) {
  return prefs.getInt(whatsNewLastSeenVersionCodeKey);
}

Future<void> writeWhatsNewLastSeenVersionCode(
  SharedPreferences prefs,
  int versionCode,
) {
  return prefs.setInt(whatsNewLastSeenVersionCodeKey, versionCode);
}

/// Chooses whether to present release notes for [currentVersionCode].
///
/// A missing stored code means this install has never recorded a build.
/// When the home tutorial is still pending, that first session is not an
/// update, so the sheet stays closed and the code is stored for next time.
/// A stored code below [currentVersionCode] is an update and should show
/// when [hasChangelog] is true.
WhatsNewOutcome decideWhatsNewPresentation({
  required int? lastSeenVersionCode,
  required int currentVersionCode,
  required bool homeTutorialCompleted,
  required bool hasChangelog,
}) {
  if (lastSeenVersionCode != null &&
      lastSeenVersionCode >= currentVersionCode) {
    return WhatsNewOutcome.ignore;
  }
  if (lastSeenVersionCode == null && !homeTutorialCompleted) {
    return WhatsNewOutcome.recordSilently;
  }
  if (!hasChangelog) return WhatsNewOutcome.recordSilently;
  return WhatsNewOutcome.show;
}
