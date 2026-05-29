import 'package:collectarr_app/features/library/home/home_top_nav.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
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

    final types = fallbackMediaCatalog.take(3).toList(growable: false);

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
    final firstCenterX = tester.getRect(find.text(types.first.pluralLabel)).center.dx;
    final lastCenterX = tester.getRect(find.text(types.last.pluralLabel)).center.dx;
    final contentCenterX = (firstCenterX + lastCenterX) / 2;

    expect((contentCenterX - stripCenterX).abs(), lessThan(12));
  });
}