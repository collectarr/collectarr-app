import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/game/add/contribution.dart';
import 'package:collectarr_app/features/library/kinds/game/add/search_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release regions map to the reference Add Games regions', () {
    expect(gameAddRegionFor('NTSC-U/C (US/Canada)'), GameAddRegion.us);
    expect(gameAddRegionFor('PAL (Europe/Australia)'), GameAddRegion.eu);
    expect(gameAddRegionFor('NTSC-J (Japan)'), GameAddRegion.jp);
    expect(gameAddRegionFor('Australia'), GameAddRegion.au);
    expect(gameAddRegionFor('Region Free'), GameAddRegion.other);
    expect(gameAddRegionFor(null), isNull);
  });

  test('Add Games configures the Platform search tab', () {
    final search = gameKindAdd.search;
    final tab = search.input.codeSearchTab;
    expect(tab, isNotNull);
    expect(tab!.label, 'Platform');
    expect(tab.hintText, 'Filter games...');
    expect(tab.icon, AppIcons.viewList);
  });

  test('Add Games detects search input across Title, Barcode, and Platform',
      () {
    final input = gameKindAdd.search.input;

    expect(input.hasSearchInput(LibraryAddSearchContext()), isFalse);
    expect(
        input.hasSearchInput(LibraryAddSearchContext(query: 'Zelda')), isTrue);
    expect(
      input.hasSearchInput(
          LibraryAddSearchContext(identifierCode: '045496590437')),
      isTrue,
    );
    expect(
      input.hasSearchInput(LibraryAddSearchContext(codeQuery: 'Mario')),
      isTrue,
    );
    expect(
      input.hasSearchInput(
        LibraryAddSearchContext(
          advancedFilters: {
            gameAddPlatformFilterId:
                const LibraryAddOptionFilterValue('Nintendo Switch'),
          },
        ),
      ),
      isFalse,
      reason: 'Core cannot list a platform without search text',
    );
  });

  test('Add Games keeps the platform out of the Core query', () {
    final core = gameKindAdd.search.core;

    final query = core.inputBuilder(
      LibraryAddSearchContext(
        codeQuery: 'Metroid',
        advancedFilters: {
          gameAddPlatformFilterId:
              const LibraryAddOptionFilterValue('Nintendo Switch'),
        },
      ),
      limit: 20,
    );

    expect(query.query, 'Metroid');
    expect(query.barcode, isNull);

    final barcodeQuery = core.inputBuilder(
      LibraryAddSearchContext(identifierCode: '045496590437'),
      limit: 20,
    );
    expect(barcodeQuery.barcode, '045496590437');
  });

  test('the chosen platform narrows the results', () {
    CatalogSearchCandidate game(String platform) =>
        CatalogSearchCandidate.fromApiJson(json: {
          'id': '30000000-0000-4000-8000-000000000001',
          'kind': 'game',
          'kind_data': {
            'title': 'Brick Knight',
            'platforms': [platform],
          },
        });
    final context = LibraryAddSearchContext(
      query: 'brick',
      advancedFilters: {
        gameAddPlatformFilterId: const LibraryAddOptionFilterValue('PC'),
      },
    );
    expect(gameAddCandidateMatchesPlatform(game('PC'), context), isTrue);
    expect(gameAddCandidateMatchesPlatform(game('PlayStation 4'), context),
        isFalse);
    expect(
        gameAddCandidateMatchesPlatform(
            game('PlayStation 4'), LibraryAddSearchContext(query: 'brick')),
        isTrue);
  });
}
