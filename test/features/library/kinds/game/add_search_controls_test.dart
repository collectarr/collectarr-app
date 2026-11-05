import 'package:collectarr_app/features/library/add/models/advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/search_context.dart';
import 'package:collectarr_app/features/library/kinds/game/add/contribution.dart';
import 'package:collectarr_app/features/library/kinds/game/add/search_controls.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
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
      reason: 'Only the Platform tab lists without search text',
    );
    expect(
        input.hasSearchInput(LibraryAddSearchContext(isListing: true)), isTrue);
  });

  test('Add Games sends the platform to Core as a filter', () {
    final core = gameKindAdd.search.core;

    final query = core.inputBuilder(
      LibraryAddSearchContext(
        query: 'Metroid',
        advancedFilters: {
          gameAddPlatformFilterId:
              const LibraryAddOptionFilterValue('Nintendo Switch'),
        },
      ),
      limit: 20,
    );

    expect(query.query, 'Metroid');
    expect(query.barcode, isNull);
    expect(query.fieldFilters, {
      'platforms': ['Nintendo Switch'],
    });
    expect(query.includeTotal, isFalse);

    final barcodeQuery = core.inputBuilder(
      LibraryAddSearchContext(identifierCode: '045496590437'),
      limit: 20,
    );
    expect(barcodeQuery.barcode, '045496590437');
  });

  test('the Platform tab filters by its own text and asks for a total', () {
    final query = gameKindAdd.search.core.inputBuilder(
      LibraryAddSearchContext(
        query: 'left over from Title',
        codeQuery: 'brick',
        isListing: true,
        advancedFilters: {
          gameAddPlatformFilterId: const LibraryAddOptionFilterValue('PC'),
        },
      ),
      limit: 20,
    );

    expect(query.query, 'brick');
    expect(query.fieldFilters, {
      'platforms': ['PC'],
    });
    expect(query.includeTotal, isTrue);
    expect(query.onePerTitle, isTrue);
    expect(query.toQueryParameters()['include_total'], isTrue);
    expect(query.toQueryParameters()['one_per_title'], isTrue);
  });

  test('the Platform tab is a listing scoped by the platform filter', () {
    final listing = gameKindAdd.search.input.codeSearchTab!.listing!;

    expect(listing.scopeFilterId, gameAddPlatformFilterId);
    expect(listing.defaultScope, 'PC');
  });

  test('a completeness with no known tier and no value shows no summary', () {
    expect(
      gameValueSummary(const GamePersonalData(
          details: GameEntryDetails(completeness: 'Complete'))),
      isNull,
    );
    expect(
      gameValueSummary(const GamePersonalData(
          details: GameEntryDetails(completeness: 'cib'))),
      'CIB',
    );
  });
}
