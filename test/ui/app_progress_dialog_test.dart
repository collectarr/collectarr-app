import 'dart:async';

import 'package:collectarr_app/ui/app_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a reporting task fills the bar and captions it', (tester) async {
    final release = Completer<void>();
    late AppProgressReporter report;
    late Future<int> result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => TextButton(
                onPressed: () => result = runWithReportedProgressDialog(
                    context: context,
                    title: 'Import',
                    message: 'Importing your games...',
                    task: (reporter) async {
                      report = reporter;
                      await release.future;
                      return 2;
                    }),
                child: const Text('Start')))));
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    AppStripedProgressBar bar() =>
        tester.widget(find.byType(AppStripedProgressBar));
    expect(bar().value, isNull);

    report(0.5);
    await tester.pump();
    expect(bar().value, 0.5);
    expect(find.text('Finishing...'), findsNothing);

    report(1, 'Finishing...');
    await tester.pump();
    expect(bar().value, 1);
    expect(find.text('Finishing...'), findsOneWidget);

    release.complete();
    await tester.pump(kAppProgressMinimumDuration);
    await tester.pumpAndSettle();
    expect(await result, 2);
    expect(find.byType(AppProgressDialog), findsNothing);
  });
}
