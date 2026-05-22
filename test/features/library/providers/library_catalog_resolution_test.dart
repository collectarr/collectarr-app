import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/planned_library_configs.dart';
import 'package:collectarr_app/features/library/providers/library_catalog_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog resolution normalizes known catalog display labels', () {
    final resolvedMusic = musicLibraryConfig.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'music',
        singularLabel: 'Album',
        pluralLabel: 'Albums',
        routeSegments: ['music'],
        defaultProvider: 'musicbrainz',
        providers: ['musicbrainz'],
      ),
    ]);
    final resolvedTv = tvLibraryConfig.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'tv',
        singularLabel: 'Show',
        pluralLabel: 'Shows',
        routeSegments: ['tv'],
        defaultProvider: 'tmdb',
        providers: ['tmdb'],
      ),
    ]);

    expect(resolvedMusic.singularLabel, 'Music');
    expect(resolvedMusic.pluralLabel, 'Music');
    expect(resolvedTv.singularLabel, 'TV Show');
    expect(resolvedTv.pluralLabel, 'TV Shows');
  });
}