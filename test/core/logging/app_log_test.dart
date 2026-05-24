import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppLogNotifier keeps only the most recent 200 entries', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(appLogProvider.notifier);
    for (var index = 0; index < 205; index++) {
      notifier.info('sync', 'message-$index');
    }

    final entries = container.read(appLogProvider);
    expect(entries, hasLength(200));
    expect(entries.first.message, 'message-5');
    expect(entries.last.message, 'message-204');
  });

  test('AppLogNotifier helper methods preserve level and clear resets state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(appLogProvider.notifier);
    notifier.info('api', 'loaded');
    notifier.warn('sync', 'lagging');
    notifier.error('flutter', 'crashed', detail: 'stack trace');

    final entries = container.read(appLogProvider);
    expect(entries.map((entry) => entry.level), [
      AppLogLevel.info,
      AppLogLevel.warning,
      AppLogLevel.error,
    ]);
    expect(entries.last.source, 'flutter');
    expect(entries.last.detail, 'stack trace');

    notifier.clear();
    expect(container.read(appLogProvider), isEmpty);
  });
}