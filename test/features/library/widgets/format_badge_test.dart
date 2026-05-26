import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatBadgeStyleForId returns known styles', () {
    final dvd = formatBadgeStyleForId('dvd');
    expect(dvd.color, const Color(0xFFC62828));
    expect(dvd.icon, Icons.album);

    final uhd = formatBadgeStyleForId('4k-uhd');
    expect(uhd.shortLabel, '4K');
    expect(uhd.color, const Color(0xFF6A1B9A));

    final bluray = formatBadgeStyleForId('blu-ray');
    expect(bluray.color, const Color(0xFF1565C0));
  });

  test('formatBadgeStyleForId returns fallback for unknown id', () {
    final unknown = formatBadgeStyleForId('betamax');
    expect(unknown.color, const Color(0xFF616161));
    expect(unknown.icon, Icons.disc_full);
  });

  testWidgets('FormatBadge.fromId renders label and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FormatBadge.fromId('blu-ray')),
      ),
    );
    expect(find.text('Blu Ray'), findsOneWidget);
    expect(find.byIcon(Icons.album), findsOneWidget);
  });

  testWidgets('FormatBadge.fromId uses shortLabel when available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FormatBadge.fromId('4k-uhd')),
      ),
    );
    expect(find.text('4K'), findsOneWidget);
  });

  testWidgets('FormatBadge compact mode hides label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FormatBadge.fromId('dvd', compact: true)),
      ),
    );
    expect(find.text('DVD'), findsNothing);
    expect(find.byIcon(Icons.album), findsOneWidget);
  });

  testWidgets('FormatBadgeRow renders format, discs, and age rating', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FormatBadgeRow(
            formatId: '4k-uhd',
            formatLabel: '4K UHD',
            discCount: 2,
            ageRating: 'PG-13',
          ),
        ),
      ),
    );
    expect(find.text('4K'), findsOneWidget);
    expect(find.text('2 Discs'), findsOneWidget);
    expect(find.text('PG-13'), findsOneWidget);
  });

  testWidgets('FormatBadgeRow renders nothing when all null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FormatBadgeRow(formatId: null),
        ),
      ),
    );
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('FormatBadge.fromFormat uses label from format', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormatBadge.fromFormat(id: 'vinyl', label: 'Vinyl'),
        ),
      ),
    );
    expect(find.text('Vinyl'), findsOneWidget);
  });
}
