import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_image_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NormalizedProviderEnvelopeV1 domain model', () {
    test('round-trips custom envelope model to and from JSON', () {
      const envelope = NormalizedProviderEnvelopeV1(
        schemaVersion: 'v1',
        provider: 'openlibrary',
        providerItemId: 'OL12345W',
        kind: 'book',
        normalized: {
          'title': 'The Hobbit',
          'page_count': 310,
          'publisher': 'George Allen & Unwin',
        },
        provenance: ProviderProvenance(
          fetchedAt: '2026-08-17T12:00:00Z',
          sourceUrl: 'https://openlibrary.org/works/OL12345W',
          rawPayloadHash: '1234567890abcdef',
          providerVersion: '1.0.0',
        ),
        images: [
          ProviderImageRef(
            provider: 'openlibrary',
            url: 'https://covers.openlibrary.org/b/id/12345-L.jpg',
            kind: 'cover',
            attribution: 'Open Library',
          ),
        ],
        attribution: ProviderAttribution(
          required: true,
          text: 'Data provided by Open Library',
          url: 'https://openlibrary.org/',
          licenseName: 'Open Library Data',
        ),
      );

      final jsonMap = envelope.toJson();
      final restored = NormalizedProviderEnvelopeV1.fromJson(jsonMap);

      expect(restored, equals(envelope));
      expect(restored.provider, 'openlibrary');
      expect(restored.providerItemId, 'OL12345W');
      expect(restored.kind, 'book');
      expect(restored.normalized['title'], 'The Hobbit');
      expect(restored.provenance.fetchedAt, '2026-08-17T12:00:00Z');
      expect(restored.images, hasLength(1));
      expect(restored.images.first.url,
          'https://covers.openlibrary.org/b/id/12345-L.jpg');
      expect(restored.attribution.required, isTrue);
      expect(restored.attribution.licenseName, 'Open Library Data');
    });

    test('loads and validates all 10 Core golden provider envelopes', () {
      final fixturesFile =
          File('tool/core_contracts/golden-provider-envelopes.json');
      expect(fixturesFile.existsSync(), isTrue,
          reason:
              'tool/core_contracts/golden-provider-envelopes.json must exist');

      final rawContent = fixturesFile.readAsStringSync();
      final jsonList = jsonDecode(rawContent) as List<dynamic>;

      expect(jsonList, hasLength(10));

      final expectedProviders = <String>{
        'openlibrary',
        'anilist',
        'musicbrainz',
        'mangadex',
        'gcd',
        'tmdb',
        'hardcover',
        'comicvine',
        'bgg',
        'igdb',
      };

      final parsedProviders = <String>{};

      for (final rawItem in jsonList) {
        final itemMap = Map<String, dynamic>.from(rawItem as Map);
        final envelope = NormalizedProviderEnvelopeV1.fromJson(itemMap);

        expect(envelope.schemaVersion, 'v1');
        expect(envelope.provider, isNotEmpty);
        expect(envelope.providerItemId, isNotEmpty);
        expect(envelope.kind, isNotEmpty);
        expect(envelope.normalized, isNotEmpty);
        expect(envelope.normalized['title'], isNotNull);
        expect(envelope.provenance.fetchedAt, isNotEmpty);
        expect(envelope.images, isNotEmpty);
        expect(envelope.images.first.url, isNotEmpty);

        parsedProviders.add(envelope.provider);

        // Verify lossless re-serialization
        final reSerialized = envelope.toJson();
        expect(reSerialized['provider'], envelope.provider);
        expect(reSerialized['provider_item_id'], envelope.providerItemId);
        expect(reSerialized['kind'], envelope.kind);
        expect(reSerialized['schema_version'], 'v1');
      }

      expect(parsedProviders, equals(expectedProviders));
    });

    test('schema file exists and matches v1 schema definitions', () {
      final schemaFile =
          File('tool/core_contracts/provider-envelope-schema-v1.json');
      expect(schemaFile.existsSync(), isTrue);

      final schema =
          jsonDecode(schemaFile.readAsStringSync()) as Map<String, dynamic>;
      expect(schema['title'], 'NormalizedProviderEnvelopeV1');
      expect(schema['type'], 'object');
      final required = List<String>.from(schema['required'] as List);
      expect(
        required,
        containsAll([
          'schema_version',
          'provider',
          'provider_item_id',
          'kind',
          'normalized',
          'provenance',
          'images',
          'attribution',
        ]),
      );
    });

    test(
        'metadataItemFromEnvelope maps NormalizedProviderEnvelopeV1 into LibraryMetadataItem correctly',
        () {
      final comicEnvelope = NormalizedProviderEnvelopeV1(
        provider: 'gcd',
        providerItemId: '123',
        kind: 'comic',
        normalized: {
          'title': 'Spider-Man',
          'item_number': '300',
          'publisher': 'Marvel Comics',
        },
        provenance: const ProviderProvenance(fetchedAt: '2026-08-20T00:00:00Z'),
        images: const [
          ProviderImageRef(
              provider: 'gcd',
              url: 'https://example.com/cover.jpg',
              kind: 'cover')
        ],
        attribution: const ProviderAttribution(required: false),
      );

      final mapper = const ComicLibraryKindProviderMapper();
      final item = mapper.metadataItemFromEnvelope(comicEnvelope);
      final meta = item.kindMetadata as ComicCatalogMetadata;

      expect(item.title, 'Spider-Man');
      expect(meta.issueNumber, '300');
      expect(meta.publisher, 'Marvel Comics');
      expect(item.coverImageUrl, 'https://example.com/cover.jpg');
    });
  });
}
