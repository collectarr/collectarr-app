import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/catalog_search_page.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'dart:convert';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/add/contribution.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/add/search_controls.dart';
import 'package:flutter_test/flutter_test.dart';

class _CaptureApi extends ApiClient {
  _CaptureApi() : super(baseUrl: 'http://unused', dio: Dio());
  MetadataSearchQuery? captured;
  @override
  Future<CatalogSearchPage> searchMetadataPage(MetadataSearchQuery query,
      {CancelToken? cancelToken}) async {
    captured = query;
    return CatalogSearchPage(items: const [], nextOffset: null, hasMore: false);
  }
}

void main() {
  test('Hardware filters survive the shared search and cache workflow',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final api = _CaptureApi();
    final input = gameHardwareCoreSearchInput(
            LibraryAddSearchContext(query: 'Pocket', advancedFilters: {
              ...gameHardwareInitialSearchFilters,
              gameHardwareAddPlatformId:
                  const LibraryAddOptionFilterValue('PC'),
            }),
            limit: 25)
        .withOffset(25);
    await searchAndCacheLibraryMetadataPage(
        api: api,
        kind: CatalogMediaKind.gameHardware,
        catalog: CatalogTransportRepository(db),
        input: input);
    expect(api.captured!.kind, 'game_hardware');
    expect(api.captured!.fieldFilters, input.fieldFilters);
    expect(api.captured!.offset, 25);
  });
  test('Hardware defaults to Consoles without starting an empty search', () {
    final search = gameHardwareKindAdd.search;
    final context = LibraryAddSearchContext(
        advancedFilters: search.input.initialAdvancedFilters);
    expect(search.input.hasSearchInput(context), isFalse);
    expect(search.core.inputBuilder(context, limit: 25).fieldFilters, {
      'hardware_type': ['Console']
    });
  });
  test(
      'platform and selected types stay distinct from title and survive pagination',
      () {
    final context = LibraryAddSearchContext(query: 'Pocket', advancedFilters: {
      ...gameHardwareInitialSearchFilters,
      gameHardwareAddPlatformId: const LibraryAddOptionFilterValue('PC'),
      GameHardwareSearchType.controllers.filterId:
          const LibraryAddOptionFilterValue('true'),
    });
    final search = gameHardwareKindAdd.search;
    expect(search.input.hasSearchInput(context), isTrue);
    final query = search.core.inputBuilder(context, limit: 25);
    expect(query.query, 'Pocket');
    expect(query.fieldFilters, {
      'platform': ['PC'],
      'hardware_type': ['Console', 'Controller']
    });
    expect(
        jsonDecode(query.withOffset(25).toQueryParameters()['field_filters']
            as String),
        query.fieldFilters);
    expect(query.withOffset(25).offset, 25);
  });
  test('clearing every type means no selected categories', () {
    final context = LibraryAddSearchContext(identifierCode: '1234567890');
    final query =
        gameHardwareKindAdd.search.core.inputBuilder(context, limit: 25);
    expect(query.barcode, '1234567890');
    expect(query.fieldFilters, {'hardware_type': <String>[]});
  });
}
