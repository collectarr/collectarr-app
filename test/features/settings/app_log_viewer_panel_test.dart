import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/features/settings/app_log_viewer_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/test_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppLogViewerPanel filters by level and source', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(appLogProvider.notifier);
    notifier.info('api', 'catalog warmed');
    notifier.error('sync', 'sync failed');
    notifier.warn('sync', 'retry scheduled');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: AppLogViewerPanel(),
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('3 entries'), findsOneWidget);
    expect(find.text('catalog warmed'), findsOneWidget);
    expect(find.text('sync failed'), findsOneWidget);
    expect(find.text('retry scheduled'), findsOneWidget);

    await tester.tap(find.text('Errors'));
    await pumpUntilSettled(tester);

    expect(find.text('1 entries'), findsOneWidget);
    expect(find.text('sync failed'), findsOneWidget);
    expect(find.text('catalog warmed'), findsNothing);
    expect(find.text('retry scheduled'), findsNothing);

    await tester.tap(find.byType(DropdownButton<String?>));
    await pumpUntilSettled(tester);
    await tester.tap(find.text('api').last);
    await pumpUntilSettled(tester);

    expect(find.text('No entries match the current filter'), findsOneWidget);
  });

  testWidgets('AppLogViewerPanel copies entries and toggles detail expansion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? clipboardText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      switch (call.method) {
        case 'Clipboard.setData':
          clipboardText = (call.arguments as Map)['text'] as String?;
          return null;
        case 'Clipboard.getData':
          return <String, dynamic>{'text': clipboardText};
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(appLogProvider.notifier);
    notifier.error('sync', 'sync failed', detail: 'stack trace line');
    notifier.info('api', 'catalog warmed');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: AppLogViewerPanel(),
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('stack trace line'), findsNothing);

    await tester.tap(find.text('sync failed'));
    await pumpUntilSettled(tester);
    expect(find.text('stack trace line'), findsOneWidget);

    await tester.tap(find.text('sync failed'));
    await pumpUntilSettled(tester);
    expect(find.text('stack trace line'), findsNothing);

    await tester.tap(find.byTooltip('Copy all to clipboard'));
    await pumpUntilSettled(tester);

    final clipboardData = await Clipboard.getData('text/plain');
    expect(clipboardData?.text, contains('[INFO]'));
    expect(clipboardData?.text, contains('[ERROR]'));
    expect(clipboardData?.text, contains('stack trace line'));
    expect(find.text('Log copied'), findsOneWidget);
  });
}