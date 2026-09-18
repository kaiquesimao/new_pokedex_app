import 'package:flutter/foundation.dart';

/// Immutable score entry for a completed game session.
@immutable
class const LeaderboardEntry({
  required final String playerName,
  required final int score,
  required final DateTime completedAt,
  final bool isCurrentUser = false,
});
