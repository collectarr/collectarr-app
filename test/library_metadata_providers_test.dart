import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known metadata provider registry resolves providers by kind', () {
    expect(
      collectarrMetadataProviderRegistry
          .forKind('comic')
          .map((provider) => provider.id),
      ['gcd', 'comicvine'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind('game')
          .map((provider) => provider.id),
      ['igdb'],
    );
    expect(
      collectarrMetadataProviderRegistry
          .forKind('bluray')
          .map((provider) => provider.id),
      ['tmdb'],
    );
  });

  test('known metadata provider registry resolves provider details', () {
    final comicVine = collectarrMetadataProviderRegistry.byId('comicvine');

    expect(comicVine?.requiresApiKey, isTrue);
    expect(comicVine?.usagePolicy?.nonCommercialOnly, isTrue);
    expect(collectarrMetadataProviderRegistry.byId('missing'), isNull);
  });
}
