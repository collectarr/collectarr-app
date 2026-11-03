import 'package:collectarr_app/features/library/add/launcher.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/controllers/session_controller.dart';
import 'package:collectarr_app/features/library/add/dialog.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/series.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../support/fixtures/test_constants.dart';
import '../../../../../support/widget/library_add_test_harness.dart';

void main() {
  test('a Core series names its volume, publisher and years', () {
    final series = comicAddSeriesFromJson({
      'series_title': 'Fixture',
      'publisher': 'Marvel',
      'volume_start_year': 2018,
      'first_year': 2018,
      'last_year': 2019,
      'issue_count': 2,
      'cover_image_url': null,
    });
    expect(series.title, 'Fixture (2018)');
    expect(series.countLabel, '2');
    expect(series.details, 'Marvel');
    expect(series.period, '2018 - 2019');
    expect(series.query, {
      'series_title': 'Fixture',
      'publisher': 'Marvel',
      'volume_start_year': 2018,
    });
    final bare = comicAddSeriesFromJson(
        {'series_title': 'Bare', 'issue_count': 1, 'first_year': 2001});
    expect(bare.title, 'Bare');
    expect(bare.details, isNull);
    expect(bare.period, '2001');
    expect(bare.query, {'series_title': 'Bare'});
  });

  test('the Series tab lists a series, then checks all of its issues',
      () async {
    SharedPreferences.setMockInitialValues({});
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    final api = _SeriesApiFake();
    final controller = LibraryAddSessionController(
      kind: CatalogMediaKind.comic,
      api: api,
      catalog: CatalogTransportRepository(db),
      entryMutations: container.read(libraryEntryMutationsProvider),
      wishlistMutations: container.read(wishlistMutationsProvider),
      trackingMutations: container.read(trackingMutationsProvider),
    );
    addTearDown(controller.dispose);

    controller.setMode(LibraryAddDialogMode.browse);
    await controller.searchBrowseGroups('fixture');
    final found = controller.state.browse.found.single;
    expect(found.title, 'Fixture (2018)');

    await controller.openBrowseGroup(found);
    expect(api.issueQuery, {
      'series_title': 'Fixture',
      'publisher': 'Marvel',
      'volume_start_year': 2018
    });
    final ids = [
      for (final item in controller.state.search.results) item.reference.id
    ];
    expect(ids, ['issue-1', 'issue-2']);
    controller.setAllResultsChecked(ids, true);
    expect(controller.state.selection.checkedResultIds, {'issue-1', 'issue-2'});

    controller.closeBrowseGroup();
    expect(controller.state.browse.opened, isNull);
    expect(controller.state.browse.found, [found]);
    expect(controller.state.search.results, isEmpty);
    expect(controller.state.selection.checkedResultIds, isEmpty);

    await controller.openBrowseGroup(found);
    controller.setMode(LibraryAddDialogMode.search);
    expect(controller.state.search.results, isEmpty);
  });

  testWidgets('Add Comics by Series lists the issues beside the series list',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    configureLibraryAddDesktopViewport(tester);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider
              .overrideWith((ref) async => fallbackMediaCatalog),
          localDatabaseProvider.overrideWithValue(db),
          apiClientProvider.overrideWithValue(_SeriesApiFake()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: ComicRegistration(),
              autoLookupInitialIdentifier: false,
            ),
          ),
        ),
      ),
    );
    await pumpUntilSettled(tester);

    // Add Comics opens on Series, as in the reference.
    await tester.enterText(
        find.byKey(const ValueKey('library-add-browse-field')), 'fixture');
    await tester.tap(find.byKey(const ValueKey('library-add-search-button')));
    await pumpUntilSettled(tester);
    expect(find.text('Add it manually'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('2018 - 2019'), findsOneWidget);

    await tester.tap(find.text('Fixture (2018)'));
    await pumpUntilSettled(tester);
    final header = find.byKey(const ValueKey('library-add-browse-header'));
    expect(
        find.descendant(
            of: header, matching: find.text('Marvel (2018 - 2019)')),
        findsOneWidget);
    expect(find.descendant(of: header, matching: find.text('Fixture (2018)')),
        findsOneWidget);
    // The series list stays beside its issues, shown as cover blocks that
    // end with a "Not found?" block, as the series list does.
    expect(find.byKey(const ValueKey('library-add-cover-not-found')),
        findsOneWidget);
    expect(find.text('All (2)'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('library-add-cover-grid')), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('Mar\n2018'), findsOneWidget);
    expect(find.text('Foil'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('library-add-sort-issues')));
    await pumpUntilSettled(tester);
    expect(
        tester.getTopLeft(find.text('#2')).dx <
            tester.getTopLeft(find.text('#1')).dx,
        isTrue);
    await tester.tap(find.byKey(const ValueKey('library-add-layout-list')));
    await pumpUntilSettled(tester);
    expect(
        find.byKey(const ValueKey('library-add-cover-list')), findsOneWidget);
    expect(find.text('2018, Mar.'), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byKey(const ValueKey('library-add-check-all')),
        matching: find.byKey(const ValueKey('library-add-result-checkbox'))));
    await pumpUntilSettled(tester);
    expect(find.text('2 selected'), findsOneWidget);

    // Typing a series lists suggestions; picking one opens it alone.
    await tester.enterText(
        find.byKey(const ValueKey('library-add-browse-field')), 'fixt');
    await tester.pump(const Duration(milliseconds: 400));
    await pumpUntilSettled(tester);
    expect(find.byKey(const ValueKey('library-add-browse-suggestions')),
        findsOneWidget);
    expect(find.text('Search for "fixt"'), findsOneWidget);
    await tester.tap(
        find.byKey(const ValueKey('library-add-suggested-Fixture (2018)')));
    await pumpUntilSettled(tester);
    expect(find.byKey(const ValueKey('library-add-browse-suggestions')),
        findsNothing);
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('2 selected'), findsNothing);

    await tester.tap(find.text('Issue'));
    await pumpUntilSettled(tester);
    expect(find.text('2 selected'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  for (final size in [
    const Size(320, 700),
    const Size(407, 904),
    const Size(850, 407)
  ]) {
    testWidgets('mobile Add uses one page through series and issues at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            mediaCatalogProvider
                .overrideWith((ref) async => fallbackMediaCatalog),
            localDatabaseProvider.overrideWithValue(db),
            apiClientProvider.overrideWithValue(_SeriesApiFake()),
          ],
          child: MaterialApp(
              home: Scaffold(
            appBar: AppBar(title: const Text('Outer app header')),
            body: Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                    builder: (context) => Center(
                        child: TextButton(
                            onPressed: () => showLibraryAddDialog(
                                context: context,
                                type: const ComicRegistration()),
                            child: const Text('Open Add'))))),
          ))));
      await tester.tap(find.text('Open Add'));
      await pumpUntilSettled(tester);
      expect(find.byKey(const Key('add.method-picker')), findsOneWidget);
      final pickerTitle = find.text('Add Comics from CLR Core');
      expect(pickerTitle, findsOneWidget);
      expect(
        find.text(
            'Adding comics to the app is done by searching our CLR Core central online comic database, either by cover, barcode or series / issue.'),
        findsOneWidget,
      );
      final pickerHeader = tester.widget<Container>(
        find.ancestor(of: pickerTitle, matching: find.byType(Container)).first,
      );
      expect(pickerHeader.color, const Color(0xFF00577F));
      await tester
          .ensureVisible(find.byKey(const ValueKey('add.method.search')));
      await tester.tap(find.byKey(const ValueKey('add.method.search')));
      await pumpUntilSettled(tester);
      expect(find.text('Outer app header'), findsNothing);
      expect(find.text('My Comics'), findsOneWidget);
      expect(find.text(size.width < 360 ? 'COLLECTARR' : 'COLLECTARR COMICS'),
          findsOneWidget);
      expect(find.text('Series'), findsOneWidget);
      expect(find.text('Issue'), findsOneWidget);
      expect(find.text('Barcode'), findsOneWidget);
      expect(find.text('Cover'), findsOneWidget);
      final field = find.byKey(const ValueKey('library-add-browse-field'));
      await tester.enterText(field, 'fixture');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await pumpUntilSettled(tester);
      await tester.tap(find.text('Fixture (2018)'));
      await pumpUntilSettled(tester);
      expect(find.text('All (2)'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('library-add-cover-grid')), findsOneWidget);
      expect(
          tester
              .getSize(find.byKey(const ValueKey('library-add-cover-grid')))
              .width,
          lessThanOrEqualTo(size.width));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('#1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('#1'));
      await pumpUntilSettled(tester);
      expect(find.text('Confirm your selection'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Back to results'));
      await pumpUntilSettled(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Fixture (2018)'));
      await pumpUntilSettled(tester);
      expect(
          find.byKey(const ValueKey('library-add-cover-grid')), findsNothing);
      expect(find.text('Fixture (2018)'), findsOneWidget);
      await tester.tap(find.text('Barcode'));
      await pumpUntilSettled(tester);
      expect(find.byKey(const ValueKey('library-add-barcode-field')),
          findsOneWidget);
      await tester.ensureVisible(find.text('Issue'));
      await tester.tap(find.text('Issue'));
      await pumpUntilSettled(tester);
      expect(find.byKey(const ValueKey('library-add-query-field')),
          findsOneWidget);
      await tester.ensureVisible(find.text('Cover'));
      await tester.tap(find.text('Cover'));
      await pumpUntilSettled(tester);
      expect(find.text('Scan cover'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(BackButton));
      await pumpUntilSettled(tester);
      expect(find.text('Outer app header'), findsOneWidget);
      if (size.width == 407) {
        for (final method in ['barcode', 'cover']) {
          await tester.tap(find.text('Open Add'));
          await pumpUntilSettled(tester);
          await tester.tap(find.byKey(ValueKey('add.method.$method')));
          await pumpUntilSettled(tester);
          if (method == 'barcode') {
            expect(find.byKey(const ValueKey('library-add-barcode-field')),
                findsOneWidget);
          } else {
            expect(find.text('Scan cover'), findsOneWidget);
          }
          await tester.tap(find.byType(BackButton));
          await pumpUntilSettled(tester);
        }
        await tester.tap(find.text('Open Add'));
        await pumpUntilSettled(tester);
        await tester.tap(find.byType(CheckboxListTile));
        await tester.tap(find.byKey(const ValueKey('add.method.search')));
        await pumpUntilSettled(tester);
        await tester.tap(find.byType(BackButton));
        await pumpUntilSettled(tester);
        await tester.tap(find.text('Open Add'));
        await pumpUntilSettled(tester);
        expect(find.byKey(const Key('add.method-picker')), findsNothing);
        expect(find.byType(LibraryAddDialog), findsOneWidget);
        await tester.tap(find.byType(BackButton));
        await pumpUntilSettled(tester);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }
}

class _SeriesApiFake extends ApiClient {
  _SeriesApiFake() : super(baseUrl: 'http://unused', dio: Dio());

  Map<String, dynamic>? issueQuery;

  @override
  Future<Map<String, dynamic>> getCatalogItemJson(
          {required CatalogMediaKind kind,
          required String id,
          CancelToken? cancelToken}) async =>
      {
        'id': id,
        'kind': kind.apiValue,
        'kind_data': {
          'title': 'Fixture #1',
          'series_title': 'Fixture',
          'issue_number': '1'
        },
      };

  @override
  Future<List<Map<String, dynamic>>> getJsonRows(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    switch (path) {
      case '/api/v1/metadata/comics/series':
        return [
          {
            'series_title': 'Fixture',
            'publisher': 'Marvel',
            'volume_start_year': 2018,
            'first_year': 2018,
            'last_year': 2019,
            'issue_count': 2,
            'cover_image_url': null,
          },
        ];
      case '/api/v1/metadata/comics/series/issues':
        issueQuery = queryParameters;
        return [
          for (final number in ['1', '2'])
            {
              'id': 'issue-$number',
              'kind': 'comic',
              'kind_data': {
                'title': 'Fixture #$number',
                'series_title': 'Fixture',
                'issue_number': number,
                if (number == '1') ...{
                  'cover_date': {'year': 2018, 'month': 3},
                  'variant_description': 'Foil',
                },
              },
            },
        ];
    }
    throw StateError('Unexpected test request: $path');
  }
}
