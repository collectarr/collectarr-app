import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cover badges shows ownership state when item has no local state',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryCoverBadges(
          isOwned: false,
          isTracked: false,
          isWishlisted: false,
        ),
      ),
    );

    expect(find.byType(LibraryCoverBadge), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
  });

  testWidgets('cover badges renders owned and wishlist markers',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryCoverBadges(
          isOwned: true,
          isTracked: false,
          isWishlisted: true,
        ),
      ),
    );

    expect(find.byType(LibraryCoverBadge), findsNWidgets(2));
    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('cover badges renders missing cover and metadata markers',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryCoverBadges(
          isOwned: false,
          isTracked: false,
          isWishlisted: false,
          hasMissingCover: true,
          hasMissingMetadata: true,
        ),
      ),
    );

    expect(find.byType(LibraryCoverBadge), findsNWidgets(3));
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(find.byIcon(Icons.manage_search), findsOneWidget);
  });

  testWidgets('cover badges renders key and slab markers', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryCoverBadges(
          isOwned: true,
          isTracked: false,
          isWishlisted: false,
          keyLabel: 'Key item: First appearance',
          slabLabel: 'Slabbed - CGC',
          notesLabel: 'Notes: Newsstand copy',
        ),
      ),
    );

    expect(find.byIcon(Icons.label_important), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    expect(find.byIcon(Icons.sticky_note_2_outlined), findsOneWidget);
  });

  testWidgets('cover badges renders grade, signed, and value markers',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryCoverBadges(
          isOwned: true,
          isTracked: false,
          isWishlisted: false,
          gradeLabel: 'Grade 9.8',
          signedLabel: 'Signed',
          valueLabel: 'Value USD 25.00',
        ),
      ),
    );

    expect(find.byIcon(Icons.star_rate), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
  });

  testWidgets('status icons shows wishlist marker only when present',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryItemStatusIcons(
          isOwned: true,
          isTracked: false,
          isWishlisted: false,
        ),
      ),
    );

    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);
  });

  testWidgets('status icons include metadata warnings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryItemStatusIcons(
          isOwned: true,
          isTracked: false,
          isWishlisted: false,
          hasMissingCover: true,
          hasMissingMetadata: true,
        ),
      ),
    );

    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('status icons include collector markers', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryItemStatusIcons(
          isOwned: true,
          isTracked: false,
          isWishlisted: false,
          hasKeyMarker: true,
          hasSlabMarker: true,
          hasNotesMarker: true,
        ),
      ),
    );

    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.label_important), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('status icons collapse safely in narrow width', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 52,
            child: LibraryItemStatusIcons(
              isOwned: true,
              isTracked: true,
              isWishlisted: true,
              hasMissingCover: true,
              hasMissingMetadata: true,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.text('+4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cover badges renders tracked marker for tracking-only items',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryCoverBadges(
          isOwned: false,
          isTracked: true,
          isWishlisted: false,
        ),
      ),
    );

    expect(find.byIcon(Icons.equalizer), findsOneWidget);
  });
}
