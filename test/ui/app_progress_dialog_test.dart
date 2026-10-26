import 'dart:async';

import 'package:collectarr_app/ui/app_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('completion removes its own progress route, not a newer dialog',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    final release = Completer<String>();
    late Future<String> result;
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      home: Builder(
          builder: (context) => TextButton(
                onPressed: () {
                  result = runWithProgressDialog(
                      context: context,
                      title: 'Working',
                      message: 'Generating...',
                      task: () => release.future);
                },
                child: const Text('Start'),
              )),
    ));
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    unawaited(showDialog<void>(
        context: navigator.currentContext!,
        builder: (_) => const AlertDialog(title: Text('Newer dialog'))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    release.complete('done');
    await tester.pump(kAppProgressMinimumDuration);
    await tester.pumpAndSettle();
    expect(await result, 'done');
    expect(find.byType(AppProgressDialog), findsNothing);
    expect(find.text('Newer dialog'), findsOneWidget);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
  });

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
