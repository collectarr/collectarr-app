import 'package:collectarr_app/features/library/home/home_top_nav.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_nav_button.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('library nav strip centers its buttons when they fit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const types = [
      CatalogMediaType(
        kind: 'comic',
        singularLabel: 'Comic',
        pluralLabel: 'Comics',
        routeSegments: ['comics'],
      ),
      CatalogMediaType(
        kind: 'manga',
        singularLabel: 'Manga',
        pluralLabel: 'Manga',
        routeSegments: ['manga'],
      ),
      CatalogMediaType(
        kind: 'movie',
        singularLabel: 'Movie',
        pluralLabel: 'Movies',
        routeSegments: ['movies'],
      ),
      CatalogMediaType(
        kind: 'tv',
        singularLabel: 'Show',
        pluralLabel: 'Shows',
        routeSegments: ['tv'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 42,
            child: MediaLibraryNavStrip(
              types: types,
              counts: const {},
              registry: collectarrLibraryTypes,
              selectedKind: 'comic',
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    final strip = find.byType(MediaLibraryNavStrip);
    expect(strip, findsOneWidget);

    final navButtons = find.byType(MediaLibraryNavButton);
    expect(navButtons, findsNWidgets(types.length));
    final stripRect = tester.getRect(strip);
    final firstRect = tester.getRect(navButtons.at(0));
    final lastRect = tester.getRect(navButtons.at(types.length - 1));

    expect(firstRect.left, greaterThanOrEqualTo(stripRect.left));
    expect(lastRect.right, lessThanOrEqualTo(stripRect.right));
  });

  testWidgets('home sync button is icon only', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          syncControllerProvider.overrideWith(
            (ref) => _FakeSyncController(ref),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MediaLibraryNav(
              types: const [
                CatalogMediaType(
                  kind: 'comic',
                  singularLabel: 'Comic',
                  pluralLabel: 'Comics',
                  routeSegments: ['comics'],
                ),
              ],
              counts: const {},
              selectedLabel: 'Libraries',
              registry: collectarrLibraryTypes,
              selectedKind: 'comic',
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sync'), findsNothing);
    expect(find.byIcon(Icons.sync_outlined), findsOneWidget);
  });
}

class _FakeSyncController extends SyncController {
  _FakeSyncController(super.ref);
}