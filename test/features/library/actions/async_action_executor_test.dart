import 'dart:async';

import 'package:collectarr_app/features/library/actions/async_action_executor.dart';
import 'package:collectarr_app/features/library/actions/async_action_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('callbacks retained after a host is removed do not start work',
      (tester) async {
    late AsyncActionRun run;
    await tester.pumpWidget(MaterialApp(home: AsyncActionHost(
      builder: (context, busy, callback) {
        run = callback;
        return const SizedBox.shrink();
      },
    )));
    await tester.pumpWidget(const SizedBox.shrink());
    run('Late action', () => fail('Removed host started work'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  test('one action runs at a time and completion permits a new attempt',
      () async {
    final executor = AsyncActionExecutor();
    addTearDown(executor.dispose);
    final pending = Completer<void>();
    var calls = 0;
    final states = <bool>[];
    executor.addListener(() => states.add(executor.isRunning));
    final first = executor.run(() {
      calls++;
      return pending.future;
    }, onError: (error, stack) => fail('$error'));
    expect(await executor.run(() => calls++, onError: (_, __) {}), isFalse);
    expect(calls, 1);
    expect(executor.isRunning, isTrue);
    pending.complete();
    expect(await first, isTrue);
    expect(await executor.run(() => calls++, onError: (_, __) {}), isTrue);
    expect(calls, 2);
    expect(states, [true, false, true, false]);
  });

  test('synchronous and asynchronous failures are reported and release busy',
      () async {
    final executor = AsyncActionExecutor();
    addTearDown(executor.dispose);
    final errors = <Object>[];
    final error = StateError('failure');
    void report(Object value, StackTrace stack) {
      errors.add(value);
      expect(stack.toString(), isNotEmpty);
    }

    expect(await executor.run(() => throw error, onError: report), isFalse);
    expect(executor.isRunning, isFalse);
    expect(
        await executor.run(() async => throw error, onError: report), isFalse);
    expect(executor.isRunning, isFalse);
    expect(errors, [same(error), same(error)]);
    expect(await executor.run(() {}, onError: report), isTrue);
  });

  test('completion after disposal does not notify or admit new work', () async {
    final executor = AsyncActionExecutor();
    final pending = Completer<void>();
    var notifications = 0;
    executor.addListener(() => notifications++);
    final running = executor.run(() => pending.future, onError: (_, __) {});
    executor.dispose();
    pending.complete();
    await running;
    expect(notifications, 1);
    expect(await executor.run(() => fail('disposed'), onError: (_, __) {}),
        isFalse);
  });

  testWidgets('standalone actions disable repeats, report failure and retry',
      (tester) async {
    var pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AsyncActionHost(
            builder: (context, busy, run) => FilledButton(
                  onPressed: busy
                      ? null
                      : () => run('Save', () {
                            calls++;
                            return pending.future;
                          }),
                  child: const Text('Save'),
                )),
      ),
    ));
    final button = find.widgetWithText(FilledButton, 'Save');
    await tester.tap(button);
    // Exercise the same callback again before the disabled state rebuilds.
    tester.widget<FilledButton>(button).onPressed!();
    expect(calls, 1);
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    pending.completeError(StateError('disk full'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Save failed:'), findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    pending = Completer<void>();
    await tester.tap(button);
    expect(calls, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    pending.completeError(StateError('late failure'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
