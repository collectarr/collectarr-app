import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/add/models/library_add_content_scope.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tv add scope classifies series, seasons, and releases', () {
    final series = LibraryMetadataItem.fromMetadataMap({
      'id': 'tv-series',
      'kind': 'tv',
      'title': 'Example Show',
    });
    final season = LibraryMetadataItem.fromMetadataMap({
      'id': 'tv-season',
      'kind': 'tv',
      'title': 'Example Show',
      'item_number': 'Season 1',
      'series': {
        'series_title': 'Example Show',
        'season_number': 1,
      },
    });
    final release = LibraryMetadataItem.fromMetadataMap({
      'id': 'tv-release',
      'kind': 'tv',
      'title': 'Example Show',
      'item_number': 'Disc 1',
      'physical_format': 'Blu-ray',
    });

    expect(
      libraryAddContentScopeForItem(series),
      LibraryAddContentScope.series,
    );
    expect(
      libraryAddContentScopeForItem(season),
      LibraryAddContentScope.season,
    );
    expect(
      libraryAddContentScopeForItem(release),
      LibraryAddContentScope.release,
    );
  });

  test('tv add scope respects scope toggles for core items', () {
    final series = LibraryMetadataItem.fromMetadataMap({
      'id': 'tv-series',
      'kind': 'tv',
      'title': 'Example Show',
    });
    final season = LibraryMetadataItem.fromMetadataMap({
      'id': 'tv-season',
      'kind': 'tv',
      'title': 'Example Show',
      'series': {
        'series_title': 'Example Show',
        'season_number': 2,
      },
    });
    final release = LibraryMetadataItem.fromMetadataMap({
      'id': 'tv-release',
      'kind': 'tv',
      'title': 'Example Show',
      'item_number': 'Disc 1',
      'variant': 'Season Box Set',
    });

    expect(
      libraryAddMatchesContentScope(
        type: tvLibraryConfig,
        item: series,
        showSeriesResults: true,
        showSeasonResults: false,
        showReleaseResults: false,
      ),
      isTrue,
    );
    expect(
      libraryAddMatchesContentScope(
        type: tvLibraryConfig,
        item: season,
        showSeriesResults: false,
        showSeasonResults: true,
        showReleaseResults: false,
      ),
      isTrue,
    );
    expect(
      libraryAddMatchesContentScope(
        type: tvLibraryConfig,
        item: release,
        showSeriesResults: false,
        showSeasonResults: false,
        showReleaseResults: true,
      ),
      isTrue,
    );
    expect(
      libraryAddMatchesContentScope(
        type: tvLibraryConfig,
        item: season,
        showSeriesResults: true,
        showSeasonResults: false,
        showReleaseResults: false,
      ),
      isFalse,
    );
  });
}
