import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cover badges hides when item has no local state',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryCoverBadges(isOwned: false, isWishlisted: false),
      ),
    );

    expect(find.byType(LibraryCoverBadge), findsNothing);
  });

  testWidgets('cover badges renders owned and wishlist markers',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryCoverBadges(isOwned: true, isWishlisted: true),
      ),
    );

    expect(find.byType(LibraryCoverBadge), findsNWidgets(2));
    expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('status icons shows wishlist marker only when present',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LibraryItemStatusIcons(isOwned: true, isWishlisted: false),
      ),
    );

    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNothing);
  });
}
