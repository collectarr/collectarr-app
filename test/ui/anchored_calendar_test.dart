import 'package:collectarr_app/ui/anchored_calendar.dart';
import 'package:collectarr_app/ui/theme/library_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'calendar stays inside the viewport and commits only a chosen day',
      (tester) async {
    DateTime? result;
    await tester.pumpWidget(MaterialApp(
        theme: buildLibraryTheme(),
        home: Scaffold(
          body: Align(
              alignment: Alignment.bottomRight,
              child: Builder(
                  builder: (context) => TextButton(
                        child: const Text('Choose date'),
                        onPressed: () async {
                          result = await showAppAnchoredCalendar(
                              context: context,
                              initialDate: DateTime(2026, 2, 18),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100));
                        },
                      ))),
        )));
    await tester.tap(find.text('Choose date'));
    await tester.pumpAndSettle();
    final rect = tester.getRect(find.byType(CalendarDatePicker));
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(800));
    expect(rect.bottom, lessThanOrEqualTo(600));
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    await tester.tap(find.text('19').last);
    await tester.pumpAndSettle();
    expect(result, DateTime(2026, 2, 19));
    expect(find.byType(CalendarDatePicker), findsNothing);
  });
}
