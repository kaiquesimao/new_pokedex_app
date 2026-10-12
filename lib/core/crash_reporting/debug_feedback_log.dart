import 'package:pokedex_app/core/crash_reporting/debug_feedback_log_stub.dart'
    if (dart.library.io) 'package:pokedex_app/core/crash_reporting/debug_feedback_log_io.dart';

void debugFeedbackLog({
  required String hypothesisId,
  required String location,
  required String message,
  required Map<String, Object?> data,
}) {
  writeDebugFeedbackLog(
    hypothesisId: hypothesisId,
    location: location,
    message: message,
    data: data,
  );
}
