import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/crash_reporting/sentry_event_scrubber.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('scrubSentryEvent', () {
    test('redacts sensitive request headers', () {
      final event = SentryEvent(
        request: SentryRequest(
          url: 'https://example.test/api',
          headers: const {
            'Authorization': 'Bearer secret-token',
            'Cookie': 'session=abc',
            'Accept': 'application/json',
          },
        ),
      );

      final scrubbed = scrubSentryEvent(event, Hint());

      expect(scrubbed, isNotNull);
      expect(scrubbed!.request!.headers['Authorization'], '[Filtered]');
      expect(scrubbed.request!.headers['Cookie'], '[Filtered]');
      expect(scrubbed.request!.headers['Accept'], 'application/json');
    });

    test('returns event unchanged when there are no headers', () {
      final event = SentryEvent(
        request: SentryRequest(url: 'https://example.test/api'),
      );

      expect(identical(scrubSentryEvent(event, Hint()), event), isTrue);
    });
  });
}
