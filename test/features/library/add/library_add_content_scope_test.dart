import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/add/models/library_add_content_scope.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tv add scope classifies series, seasons, and releases', () {
    final series = LibraryMetadataItem(
      id: 'tv-series',
      kind: 'tv',
      title: 'Example Show',
    );
    final season = LibraryMetadataItem(
      id: 'tv-season',
      kind: 'tv',
      title: 'Example Show',
      itemNumber: 'Season 1',
      series: const CatalogSeriesDetails(
        seriesTitle: 'Example Show',
        seasonNumber: 1,
      ),
    );
    final release = LibraryMetadataItem(
      id: 'tv-release',
      kind: 'tv',
      title: 'Example Show',
      itemNumber: 'Disc 1',
      physicalFormat: 'Blu-ray',
    );

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
    final series = LibraryMetadataItem(
      id: 'tv-series',
      kind: 'tv',
      title: 'Example Show',
    );
    final season = LibraryMetadataItem(
      id: 'tv-season',
      kind: 'tv',
      title: 'Example Show',
      series: const CatalogSeriesDetails(
        seriesTitle: 'Example Show',
        seasonNumber: 2,
      ),
    );
    final release = LibraryMetadataItem(
      id: 'tv-release',
      kind: 'tv',
      title: 'Example Show',
      itemNumber: 'Disc 1',
      variant: 'Season Box Set',
    );

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
