import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cover tile renders cover overlays and remains tappable',
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
              active: false,
              selected: true,
              selectionMode: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LibraryCoverTile));

    expect(tapped, isTrue);
    expect(find.byTooltip('For sale'), findsOneWidget);
    expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Superman, Vol. 4 #8A'), findsNothing);
    expect(find.text('2016'), findsNothing);
  });

  testWidgets('cover tile hides secondary metadata labels in covers mode',
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
              active: false,
              selected: false,
              selectionMode: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Spirited Away'), findsOneWidget);
    expect(find.text('Sen to Chihiro no Kamikakushi'), findsNothing);
    expect(find.text('movie-1'), findsNothing);
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
                active: false,
                selected: false,
                selectionMode: false,
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

  testWidgets('active inspection state does not show checked selection',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SizedBox(
            width: 140,
            height: 220,
            child: LibraryCoverTile(
              entry: LibraryWorkspaceEntry(
                id: 'music-1',
                mediaType: 'music',
                title: 'Lupus Dei',
                updatedAt: DateTime.utc(2026),
              ),
              active: true,
              selected: false,
              selectionMode: false,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
  });

  testWidgets('selection toggle tap does not trigger tile tap', (tester) async {
    var tileTapped = false;
    var toggleTapped = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SizedBox(
            width: 140,
            height: 220,
            child: LibraryCoverTile(
              entry: LibraryWorkspaceEntry(
                id: 'music-2',
                mediaType: 'music',
                title: 'Bible of the Beast',
                updatedAt: DateTime.utc(2026),
              ),
              active: false,
              selected: false,
              selectionMode: true,
              onTap: () => tileTapped = true,
              onSelectionToggleTap: () => toggleTapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.check_box_outline_blank));
    await tester.pumpAndSettle();

    expect(toggleTapped, isTrue);
    expect(tileTapped, isFalse);
  });
}
