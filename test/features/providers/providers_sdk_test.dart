import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTestProvider implements MetadataCapability {
  _FakeTestProvider({
    required this.descriptor,
  });

  final ProviderDescriptor descriptor;

  bool get isConfigured => true;
  String get statusMessage => 'OK';
  String get name => descriptor.name;
  ProviderId get id => ProviderId.fromValue(descriptor.name) ?? ProviderId.tmdb;

  ProviderConnector toConnector() => ProviderConnector(
        id: id,
        descriptor: descriptor,
        metadata: this,
      );

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    Object? kind,
    int limit = 25,
  }) async {
    return [
      ProviderSearchResult(
        provider: name,
        providerItemId: 'item-1',
        title: 'Search Result: $query',
        kind: kind?.toString() ?? descriptor.kind,
      ),
    ];
  }

  @override
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    Object? kind,
  }) async {
    return NormalizedProviderEnvelopeV1(
      provider: name,
      providerItemId: providerItemId,
      kind: kind?.toString() ?? descriptor.kind,
      normalized: {'title': 'Item $providerItemId'},
      provenance: const ProviderProvenance(fetchedAt: '2026-08-17T12:00:00Z'),
      images: [
        ProviderImageRef(provider: name, url: 'https://example.com/image.jpg'),
      ],
      attribution: const ProviderAttribution(required: false),
    );
  }
}

void main() {
  group('Provider SDK Domain Contracts', () {
    test('ProviderDescriptor parses json and handles kind checks', () {
      const descriptor = ProviderDescriptor(
        name: 'test_provider',
        displayName: 'Test Provider',
        kind: 'book',
        supportedKinds: ['book', 'manga'],
        requiresUserKey: true,
        requiresAttribution: true,
        termsUrl: 'https://example.com/terms',
      );

      final json = descriptor.toJson();
      final restored = ProviderDescriptor.fromJson(json);

      expect(restored, equals(descriptor));
      expect(restored.supportsKind('book'), isTrue);
      expect(restored.supportsKind('manga'), isTrue);
      expect(restored.supportsKind('movie'), isFalse);
    });

    test('ProviderSearchResult serializes and equality checks correctly', () {
      const result = ProviderSearchResult(
        provider: 'openlibrary',
        providerItemId: 'OL123W',
        title: 'The Hobbit',
        kind: 'book',
        characterPreview: ['Bilbo', 'Gandalf'],
        storyArcPreview: ['The Quest of Erebor'],
        externalIds: {'isbn': '1234567890'},
      );

      final json = result.toJson();
      final restored = ProviderSearchResult.fromJson(json);

      expect(restored, equals(result));
      expect(restored.characterPreview, contains('Bilbo'));
      expect(restored.storyArcPreview, contains('The Quest of Erebor'));
      expect(restored.externalIds['isbn'], '1234567890');
    });

    test('ProviderException hierarchy retains codes and causes', () {
      final baseEx = ProviderException(
        provider: 'openlibrary',
        message: 'Something broke',
        statusCode: 500,
        retryAfter: const Duration(seconds: 30),
      );
      expect(baseEx.toString(), contains('status: 500'));
      expect(baseEx.toString(), contains('retry-after: 30s'));

      const rateLimitEx = ProviderRateLimitException(
        provider: 'tmdb',
        message: 'Too many requests',
        retryAfter: Duration(seconds: 15),
      );
      expect(rateLimitEx.statusCode, 429);
      expect(rateLimitEx.retryAfter?.inSeconds, 15);

      const authEx = ProviderAuthException(
        provider: 'comicvine',
        message: 'Invalid API key',
      );
      expect(authEx.statusCode, 401);

      const notFoundEx = ProviderNotFoundException(
        provider: 'bgg',
        message: 'Item not found',
      );
      expect(notFoundEx.statusCode, 404);

      const cancelEx = ProviderCancelledException(provider: 'anilist');
      expect(cancelEx.message, 'Operation was cancelled');
    });

    test(
        'InMemoryProviderRegistry registers, filters, and unregisters providers',
        () {
      final bookConnector = _FakeTestProvider(
        descriptor: const ProviderDescriptor(
          name: 'openlibrary',
          displayName: 'Book Provider',
          kind: 'book',
          supportedKinds: ['book'],
        ),
      ).toConnector();
      final multiConnector = _FakeTestProvider(
        descriptor: const ProviderDescriptor(
          name: 'mangadex',
          displayName: 'Multi Provider',
          kind: 'manga',
          supportedKinds: ['manga', 'anime'],
        ),
      ).toConnector();

      final registry = InMemoryProviderConnectorRegistry([bookConnector]);
      expect(registry.getAll(), hasLength(1));
      expect(registry.get('openlibrary'), equals(bookConnector));
      expect(registry.get('OPENLIBRARY'), equals(bookConnector));
      expect(registry.get(ProviderId.openLibrary), equals(bookConnector));

      registry.register(multiConnector);
      expect(registry.getAll(), hasLength(2));
      expect(registry.getForKind('book'), contains(bookConnector));
      expect(registry.getForKind('book'), isNot(contains(multiConnector)));
      expect(registry.getForKind('manga'), contains(multiConnector));
      expect(registry.getForKind('anime'), contains(multiConnector));

      final descriptors = registry.getDescriptors();
      expect(descriptors.map((d) => d.name),
          containsAll(['openlibrary', 'mangadex']));

      registry.unregister(ProviderId.openLibrary);
      expect(registry.get(ProviderId.openLibrary), isNull);
      expect(registry.getAll(), hasLength(1));
    });

    test('ProviderCancellationToken triggers listeners on cancel', () {
      final token = ProviderCancellationToken();
      expect(token.isCancelled, isFalse);

      var notified = false;
      token.onCancelled(() {
        notified = true;
      });

      token.cancel();
      expect(token.isCancelled, isTrue);
      expect(notified, isTrue);

      var secondNotified = false;
      token.onCancelled(() {
        secondNotified = true;
      });
      expect(secondNotified, isTrue);
    });
  });
}
