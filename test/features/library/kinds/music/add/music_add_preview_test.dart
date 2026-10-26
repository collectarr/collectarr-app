import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/music/add/preview.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Core preview shows the selected album discs and track table',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final item = CatalogSearchCandidate.fromItem(CatalogItemDto.fromJson(
        jsonDecode(File('test/support/fixtures/music_core_ui_album.json')
            .readAsStringSync()) as Map<String, dynamic>));
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: Scaffold(
      body: Builder(
          builder: (context) => buildMusicAddPreview(
                context,
                LibraryAddPreviewPaneRequest(
                  type: const MusicRegistration(),
                  accent: Colors.orange,
                  item: item,
                  isFetchingPreview: false,
                  searched: true,
                ),
              )),
    ))));
    await tester.pump();
    expect(find.text('After the Rain'), findsWidgets);
    expect(find.text('The Paper Moons'), findsOneWidget);
    expect(find.text('Disc #1'), findsOneWidget);
    expect(find.text('Disc #2'), findsOneWidget);
    expect(find.text('First Light'), findsOneWidget);
    expect(find.text('Encore'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
