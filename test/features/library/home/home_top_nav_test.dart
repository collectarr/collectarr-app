import 'package:collectarr_app/features/library/home/home_top_nav.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:flutter/material.dart';
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

    final stripCenterX = tester.getRect(strip).center.dx;
    final firstCenterX = tester.getRect(find.text('Comics')).center.dx;
    final lastCenterX = tester.getRect(find.text('Shows')).center.dx;
    final contentCenterX = (firstCenterX + lastCenterX) / 2;

    expect((contentCenterX - stripCenterX).abs(), lessThan(12));
  });
}