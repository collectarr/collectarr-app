import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';
import 'package:collectarr_app/features/settings/provider_import_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PR 18: Provider Registry Consolidation', () {
    test('ProviderConnector dynamically exposes capabilities', () {
      final connector =
          defaultProviderConnectorRegistry.getById(ProviderId.aniList);

      expect(connector, isNotNull);
      expect(connector!.supportsMetadata, isTrue);
      expect(connector.supportsPersonalRead, isTrue);
      expect(connector.supportsPersonalWrite, isTrue);
      expect(connector.supportsPersonalListFileImport, isTrue);
      expect(connector.canImportPersonalList, isTrue);
      expect(connector.canPull, isTrue);
      expect(connector.canPush, isTrue);
      expect(connector.supportsBidirectionalSync, isTrue);
    });

    test('ProviderConnector without sync only exposes metadata', () {
      final connector =
          defaultProviderConnectorRegistry.getById(ProviderId.openLibrary);

      expect(connector, isNotNull);
      expect(connector!.supportsMetadata, isTrue);
      expect(connector.supportsPersonalRead, isFalse);
      expect(connector.supportsPersonalWrite, isFalse);
      expect(connector.supportsPersonalListFileImport, isFalse);
      expect(connector.canImportPersonalList, isFalse);
      expect(connector.canPull, isFalse);
      expect(connector.canPush, isFalse);
    });

    test('ProviderConnector for MyAnimeList exposes personal-list file import',
        () {
      final connector =
          defaultProviderConnectorRegistry.getById(ProviderId.myAnimeList);

      expect(connector, isNotNull);
      expect(connector!.supportsMetadata, isFalse);
      expect(connector.supportsPersonalListFileImport, isTrue);
      expect(connector.canImportPersonalList, isTrue);
      expect(connector.canPull, isFalse);
      expect(connector.canPush, isFalse);
    });

    test('ProviderImportDescriptor derives capabilities directly from registry',
        () {
      final aniListDesc = providerImportDescriptors.firstWhere(
        (d) => d.id == ProviderId.aniList,
      );
      final tmdbDesc = providerImportDescriptors.firstWhere(
        (d) => d.id == ProviderId.tmdb,
      );
      final malDesc = providerImportDescriptors.firstWhere(
        (d) => d.id == ProviderId.myAnimeList,
      );

      expect(aniListDesc.canImportPersonalList, isTrue);
      expect(aniListDesc.canPull, isTrue);
      expect(aniListDesc.canPush, isTrue);
      expect(aniListDesc.supportsAccountSync, isTrue);
      expect(aniListDesc.supportsPersonalListFileImport, isTrue);

      expect(tmdbDesc.canImportPersonalList, isTrue);
      expect(tmdbDesc.supportsPersonalListFileImport, isTrue);

      expect(malDesc.canImportPersonalList, isTrue);
      expect(malDesc.canPull, isFalse);
      expect(malDesc.supportsAccountSync, isFalse);
    });

    test('ProviderConnectorRegistry lookups by string, enum, byId, and forKind',
        () {
      final registry = defaultProviderConnectorRegistry;

      expect(registry.get('gcd'), isNotNull);
      expect(registry.get('GCD'), isNotNull);
      expect(registry.getById(ProviderId.gcd), isNotNull);
      expect(registry.byId('gcd'), isNotNull);
      expect(registry.getByName('gcd'), isNotNull);

      final comicConnectors = registry.forKind('comic');
      expect(comicConnectors.map((c) => c.id.value), contains('gcd'));
      expect(comicConnectors.map((c) => c.id.value), contains('comicvine'));

      final mangaConnectors = registry.forKind('manga');
      expect(mangaConnectors.map((c) => c.id.value), contains('mangadex'));
      expect(mangaConnectors.map((c) => c.id.value), contains('anilist'));
    });

    test(
        'collectarrMetadataProviderRegistry delegates to defaultProviderConnectorRegistry',
        () {
      final options = collectarrMetadataProviderRegistry.forKind('comic');
      expect(options.map((o) => o.id), ['gcd', 'comicvine']);

      final comicvine = collectarrMetadataProviderRegistry.byId('comicvine');
      expect(comicvine?.requiresApiKey, isTrue);
      expect(comicvine?.label, 'Comic Vine');
    });
  });
}
