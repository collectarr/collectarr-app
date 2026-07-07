import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/features/activity/global_activity_page.dart';
import 'package:collectarr_app/features/activity/global_activity_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

GlobalActivityEntry _entry(
  ActivityEventKind kind,
  String title,
  String mediaType,
  DateTime ts,
) {
  return GlobalActivityEntry(
    event: ActivityEvent(kind: kind, timestamp: ts),
    itemId: title,
    title: title,
    mediaType: mediaType,
  );
}

void main() {
  final now = DateTime.now();
  final sample = [
    _entry(ActivityEventKind.purchased, 'Dune', 'book', now),
    _entry(ActivityEventKind.watched, 'Alien', 'movie',
        now.subtract(const Duration(days: 2))),
    _entry(ActivityEventKind.finished, 'Saga', 'comic',
        now.subtract(const Duration(days: 60))),
  ];

  Widget harness() {
    return ProviderScope(
      overrides: [
        globalActivityProvider.overrideWith((ref) async => sample),
      ],
      child: const MaterialApp(home: GlobalActivityPage()),
    );
  }

  testWidgets('renders all activity entries by default', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Alien'), findsOneWidget);
    expect(find.text('Saga'), findsOneWidget);
  });

  testWidgets('filters by selected media type', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    // Media-type chips only render when more than one type is available.
    await tester.tap(find.widgetWithText(FilterChip, 'book'));
    await tester.pumpAndSettle();

    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Alien'), findsNothing);
    expect(find.text('Saga'), findsNothing);
  });

  testWidgets('filters by selected event kind', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Watched'));
    await tester.pumpAndSettle();

    expect(find.text('Alien'), findsOneWidget);
    expect(find.text('Dune'), findsNothing);
    expect(find.text('Saga'), findsNothing);
  });
}
