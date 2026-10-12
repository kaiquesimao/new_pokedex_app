import 'dart:convert';
import 'dart:io';

void writeDebugFeedbackLog({
  required String hypothesisId,
  required String location,
  required String message,
  required Map<String, Object?> data,
}) {
  try {
    File('/opt/cursor/logs/debug.log')
        .openSync(mode: FileMode.append)
        .writeStringSync(
          '${jsonEncode({'hypothesisId': hypothesisId, 'location': location, 'message': message, 'data': data, 'timestamp': DateTime.now().millisecondsSinceEpoch})}\n',
        );
  } on Object {
    // Debug logging must never affect app behavior.
  }
}
