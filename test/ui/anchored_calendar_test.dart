import 'package:collectarr_app/ui/anchored_calendar.dart';
import 'package:collectarr_app/ui/theme/library_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Future<DateTime?> Function()> open(WidgetTester tester) async {
    DateTime? result;
    var done = false;
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
                          done = true;
                        },
                      ))),
        )));
    return () async {
      expect(done, isTrue);
      return result;
    };
  }

  testWidgets('calendar stays inside the viewport and commits a chosen day',
      (tester) async {
    final result = await open(tester);
    await tester.tap(find.text('Choose date'));
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.byType(AppReferenceCalendar));
    expect(rect.size, const Size(221, 280));
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(800));
    expect(rect.bottom, lessThanOrEqualTo(600));
    expect(find.text('February 2026'), findsOneWidget);
    expect(find.text('Su'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.text('19').last);
    await tester.pumpAndSettle();
    expect(await result(), DateTime(2026, 2, 19));
    expect(find.byType(AppReferenceCalendar), findsNothing);
  });

  testWidgets('a click outside closes the calendar without a change',
      (tester) async {
    final result = await open(tester);
    await tester.tap(find.text('Choose date'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(AppReferenceCalendar), findsNothing);
    expect(await result(), isNull);
  });

  testWidgets('the title steps up to months and pages by year', (tester) async {
    await open(tester);
    await tester.tap(find.text('Choose date'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('February 2026'));
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsOneWidget);
    await tester.tap(find.text('»'));
    await tester.pumpAndSettle();
    expect(find.text('2027'), findsOneWidget);
    await tester.tap(find.text('May'));
    await tester.pumpAndSettle();
    expect(find.text('May 2027'), findsOneWidget);
  });
}
