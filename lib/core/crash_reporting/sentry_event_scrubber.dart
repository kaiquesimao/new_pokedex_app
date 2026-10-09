import 'package:sentry_flutter/sentry_flutter.dart';

const _filtered = '[Filtered]';

const _sensitiveHeaderNames = {
  'authorization',
  'cookie',
  'set-cookie',
  'x-api-key',
  'proxy-authorization',
};

/// Scrubs sensitive HTTP headers from events before they leave the device.
///
/// Keeps `sendDefaultPii` false while still allowing Dio/failed-request
/// metadata that is useful for debugging.
SentryEvent? scrubSentryEvent(SentryEvent event, Hint hint) {
  final request = event.request;
  if (request == null || request.headers.isEmpty) {
    return event;
  }

  final scrubbed = <String, String>{};
  var changed = false;
  for (final entry in request.headers.entries) {
    if (_sensitiveHeaderNames.contains(entry.key.toLowerCase())) {
      scrubbed[entry.key] = _filtered;
      changed = true;
    } else {
      scrubbed[entry.key] = entry.value;
    }
  }

  if (changed) {
    request.headers = scrubbed;
  }
  return event;
}
