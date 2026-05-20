import 'package:collectarr_app/features/library/workspace/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cover tile renders title badges and selected marker',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 140,
          height: 220,
          child: LibraryCoverTile(
            entry: LibraryWorkspaceEntry(
              id: 'comic-1',
              mediaType: 'comic',
              title: 'Superman, Vol. 4',
              itemNumber: '8A',
              isOwned: true,
              isWishlisted: true,
              updatedAt: DateTime.utc(2026),
            ),
            selected: true,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Superman, Vol. 4 #8A'));

    expect(tapped, isTrue);
    expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
