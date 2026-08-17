import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/features/calendar/calendar_page.dart';
import 'package:collectarr_app/features/calendar/calendar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_constants.dart';

void main() {
  testWidgets('calendar page renders agenda-first on compact screens',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(380, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final event = CalendarEvent(
      kind: CalendarEventKind.releaseDate,
      date: DateTime.now().add(const Duration(days: 1)),
      title: 'Batman #150',
      itemId: 'comic-150',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarEventsProvider.overrideWith((ref) => [event]),
        ],
        child: const MaterialApp(home: CalendarPage()),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Batman #150'), findsOneWidget);

    // Switch to month view
    await tester.tap(find.text('Month'));
    await pumpUntilSettled(tester);

    expect(find.byType(IconButton), findsWidgets);
  });

  testWidgets('calendar page renders month grid on desktop screens',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final event = CalendarEvent(
      kind: CalendarEventKind.loanDue,
      date: DateTime.now(),
      title: 'Spider-Man #1',
      ownedItemId: 'owned-1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarEventsProvider.overrideWith((ref) => [event]),
        ],
        child: const MaterialApp(home: CalendarPage()),
      ),
    );
    await pumpUntilSettled(tester);

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
  });
}
