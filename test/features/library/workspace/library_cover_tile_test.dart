import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cover tile renders scope, score, and selection markers',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
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
                audienceRating: '8.0',
                releaseYear: 2016,
                collectionStatus: 'for_sale',
                updatedAt: DateTime.utc(2026),
              ),
              selected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Superman, Vol. 4 #8A'));

    expect(tapped, isTrue);
    expect(find.byTooltip('For sale'), findsOneWidget);
    expect(find.text('8.0'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('2016'), findsOneWidget);
  });

  testWidgets('cover tile renders resolved and original video titles',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SizedBox(
            width: 140,
            height: 220,
            child: LibraryCoverTile(
              entry: LibraryWorkspaceEntry(
                id: 'movie-1',
                mediaType: 'movie',
                title: 'Sen to Chihiro no Kamikakushi',
                displayTitle: 'Spirited Away',
                originalTitle: 'Sen to Chihiro no Kamikakushi',
                updatedAt: DateTime.utc(2026),
              ),
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Spirited Away'), findsWidgets);
    expect(find.text('Sen to Chihiro no Kamikakushi'), findsOneWidget);
  });

  testWidgets('cover tile shows hover selection affordance and edit action',
      (tester) async {
    var editTapped = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Material(
            child: SizedBox(
              width: 140,
              height: 220,
              child: LibraryCoverTile(
                entry: LibraryWorkspaceEntry(
                  id: 'movie-1',
                  mediaType: 'movie',
                  title: 'Spirited Away',
                  updatedAt: DateTime.utc(2026),
                ),
                selected: false,
                onTap: () {},
                onEditTap: () => editTapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.byType(LibraryCoverTile)));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    expect(find.byTooltip('Edit item'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(editTapped, isTrue);
  });
}
