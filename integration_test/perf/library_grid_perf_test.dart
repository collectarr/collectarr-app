// Frame timings of the comic grid with a large library and served covers.
//
// Run in profile mode on a desktop device; the driver writes the summaries to
// build/integration_response_data.json:
//   flutter drive --profile -d windows \
//     --driver test_driver/perf_driver.dart \
//     --target integration_test/perf/library_grid_perf_test.dart
import 'dart:io';

import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_workspace_grid.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';

import '../../test/support/app/provider_overrides.dart';
import '../../test/support/app/test_app_harness.dart';
import '../../test/support/fixtures/test_constants.dart';

const _comicCount = 1500;
const _seriesCount = 150;

final _grid =
    find.byWidgetPredicate((widget) => widget is LibraryWorkspaceGrid);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('comic grid: cover load, scroll and cover-size drag',
      (tester) async {
    setUpTestAppPreferences();
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Fictional covers, served locally at the size of real catalog covers.
    final image = img.Image(width: 420, height: 630);
    for (final pixel in image) {
      pixel
        ..r = pixel.x * 255 ~/ 420
        ..g = pixel.y * 255 ~/ 630
        ..b = (pixel.x + pixel.y) % 255;
    }
    final cover = img.encodeJpg(image, quality: 85);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var served = 0;
    server.listen((request) {
      served++;
      request.response
        ..headers.contentType = ContentType('image', 'jpeg')
        ..add(cover)
        ..close();
    });
    addTearDown(() => server.close(force: true));
    // A new path per run keeps the disk cache of earlier runs out.
    final run = DateTime.now().microsecondsSinceEpoch;

    final database = LocalDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await ComicEntryRepository(database).upsertAll([
      for (var i = 0; i < _comicCount; i++)
        ComicLibraryEntry(
          id: LibraryEntryId('perf-$i'),
          metadata: ComicCatalogItem(
            id: CatalogItemRef(kind: CatalogMediaKind.comic, id: 'perf-$i'),
            title: '',
            seriesTitle: 'Series ${i % _seriesCount}',
            issueNumber: '${i ~/ _seriesCount + 1}',
            releaseDateParts:
                PartialDate(year: 1990 + i % 30, month: 1 + i % 12),
            coverImageUrl:
                'http://${server.address.address}:${server.port}/$run/cover/$i.jpg',
          ),
          personal: const ComicPersonalData(collectionStatus: 'In Collection'),
          updatedAt: DateTime.utc(2026),
        ),
    ]);

    await tester
        .pumpWidget(testApp(overrides: testAppOverrides(database: database)));
    await pumpUntilSettled(tester);
    final router =
        ProviderScope.containerOf(tester.element(find.byType(AppShell)))
            .read(appRouterProvider);

    // Cover load: from opening Comics until every visible cover is decoded.
    final load = Stopwatch()..start();
    router.go('/libraries?kind=comic');
    int visibleCovers() => find
        .descendant(of: _grid, matching: find.byType(RawImage))
        .evaluate()
        .where((element) => (element.widget as RawImage).image != null)
        .length;
    var firstCoverMs = -1;
    while (load.elapsed < const Duration(seconds: 30)) {
      await tester.pump(const Duration(milliseconds: 16));
      final shown = visibleCovers();
      if (shown > 0 && firstCoverMs < 0) {
        firstCoverMs = load.elapsedMilliseconds;
      }
      if (shown >= 12 && served > 0) break;
    }
    binding.reportData = {
      'coverLoad': {
        'firstCoverMs': firstCoverMs,
        'twelveCoversMs': load.elapsedMilliseconds,
        'coversServed': served,
      },
    };
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    final grid =
        find.descendant(of: _grid, matching: find.byType(Scrollable)).first;
    await binding.watchPerformance(() async {
      for (var i = 0; i < 8; i++) {
        await tester.fling(grid, const Offset(0, -1600), 6000);
        await tester.pump(const Duration(milliseconds: 400));
      }
      for (var i = 0; i < 8; i++) {
        await tester.fling(grid, const Offset(0, 1600), 6000);
        await tester.pump(const Duration(milliseconds: 400));
      }
      await tester.pumpAndSettle();
    }, reportKey: 'scroll');

    final slider = tester.getRect(find.byType(LibraryCoverSizeSlider));
    await binding.watchPerformance(() async {
      for (var pass = 0; pass < 3; pass++) {
        final gesture =
            await tester.startGesture(slider.centerLeft + const Offset(8, 0));
        for (var step = 0; step <= 60; step++) {
          await gesture.moveTo(slider.centerLeft +
              Offset(8 + (slider.width - 16) * step / 60, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        for (var step = 60; step >= 0; step--) {
          await gesture.moveTo(slider.centerLeft +
              Offset(8 + (slider.width - 16) * step / 60, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await gesture.up();
        await tester.pumpAndSettle();
      }
    }, reportKey: 'coverSizeDrag');

    await disposeTestApp(tester);
  });
}
