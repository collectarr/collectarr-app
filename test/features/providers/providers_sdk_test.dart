import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTestProvider implements MetadataProvider {
  _FakeTestProvider({
    required this.descriptor,
  });

  @override
  final ProviderDescriptor descriptor;

  @override
  bool get isConfigured => true;

  @override
  String get statusMessage => 'OK';

  @override
  String get name => descriptor.name;

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    String? kind,
    int limit = 25,
  }) async {
    return [
      ProviderSearchResult(
        provider: name,
        providerItemId: 'item-1',
        title: 'Search Result: $query',
        kind: kind ?? descriptor.kind,
      ),
    ];
  }

  @override
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    String? kind,
  }) async {
    return NormalizedProviderEnvelopeV1(
      provider: name,
      providerItemId: providerItemId,
      kind: kind ?? descriptor.kind,
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
      final bookProvider = _FakeTestProvider(
        descriptor: const ProviderDescriptor(
          name: 'book_prov',
          displayName: 'Book Provider',
          kind: 'book',
          supportedKinds: ['book'],
        ),
      );
      final multiProvider = _FakeTestProvider(
        descriptor: const ProviderDescriptor(
          name: 'multi_prov',
          displayName: 'Multi Provider',
          kind: 'manga',
          supportedKinds: ['manga', 'anime'],
        ),
      );

      final registry = InMemoryProviderRegistry([bookProvider]);
      expect(registry.getAll(), hasLength(1));
      expect(registry.get('book_prov'), equals(bookProvider));
      expect(registry.get('BOOK_PROV'), equals(bookProvider));

      registry.register(multiProvider);
      expect(registry.getAll(), hasLength(2));
      expect(registry.getForKind('book'), contains(bookProvider));
      expect(registry.getForKind('book'), isNot(contains(multiProvider)));
      expect(registry.getForKind('manga'), contains(multiProvider));
      expect(registry.getForKind('anime'), contains(multiProvider));

      final descriptors = registry.getDescriptors();
      expect(descriptors.map((d) => d.name),
          containsAll(['book_prov', 'multi_prov']));

      registry.unregister('book_prov');
      expect(registry.get('book_prov'), isNull);
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
