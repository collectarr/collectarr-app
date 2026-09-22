import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves a kind-owned format descriptor', () {
    final descriptor = resolveLibraryFormatBadge(
      key: 'vinyl',
      label: 'Vinyl',
      styleForKey: (_) => const FormatBadgeStyle(
        color: Colors.deepPurple,
        icon: Icons.album,
      ),
    );

    expect(descriptor, isNotNull);
    expect(descriptor!.key, 'vinyl');
    expect(descriptor.label, 'Vinyl');
  });

  testWidgets('renders an already-resolved descriptor', (tester) async {
    const descriptor = LibraryFormatBadgeDescriptor(
      key: 'vinyl',
      label: 'Vinyl',
      style: FormatBadgeStyle(color: Colors.deepPurple, icon: Icons.album),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormatBadge.fromDescriptor(descriptor: descriptor),
        ),
      ),
    );

    expect(find.text('Vinyl'), findsOneWidget);
    expect(find.byIcon(Icons.album), findsOneWidget);
  });

  testWidgets('badge row renders resolved format and universal facts',
      (tester) async {
    const descriptor = LibraryFormatBadgeDescriptor(
      key: 'vinyl',
      label: 'Vinyl',
      style: FormatBadgeStyle(color: Colors.deepPurple, icon: Icons.album),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormatBadgeRow(
            format: descriptor,
            discCount: 2,
            ageRating: 'PG-13',
          ),
        ),
      ),
    );

    expect(find.text('Vinyl'), findsOneWidget);
    expect(find.text('2 Discs'), findsOneWidget);
    expect(find.text('PG-13'), findsOneWidget);
  });
}
