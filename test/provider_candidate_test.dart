import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses provider candidate wire format', () {
    final candidate = ProviderCandidate.fromJson(const {
      'provider': 'comicvine',
      'provider_item_id': '4000-12345',
      'title': 'The Amazing Spider-Man #1',
      'kind': 'comic',
      'summary': 'A provider candidate.',
      'image_url': 'https://example.test/cover.jpg',
    });

    expect(candidate.provider, 'comicvine');
    expect(candidate.providerItemId, '4000-12345');
    expect(candidate.title, 'The Amazing Spider-Man #1');
    expect(candidate.kind, 'comic');
    expect(candidate.summary, 'A provider candidate.');
    expect(candidate.imageUrl, 'https://example.test/cover.jpg');
  });

  test('rejects older provider responses without an explicit fallback kind',
      () {
    expect(
      () => ProviderCandidate.fromJson(const {
        'provider': 'comicvine',
        'provider_item_id': '4000-legacy',
        'title': 'Legacy Candidate',
      }),
      throwsFormatException,
    );
  });

  test('uses caller fallback kind for older provider responses', () {
    final candidate = ProviderCandidate.fromJson(
      const {
        'provider': 'openlibrary',
        'provider_item_id': 'book-1',
        'title': 'Legacy Book Candidate',
      },
      fallbackKind: 'book',
    );

    expect(candidate.kind, 'book');
    final item = candidate.placeholderCatalogItem();
    expect(item.id, 'provider:openlibrary:book:book-1');
    expect(item.kind, 'book');
    expect(item.title, 'Legacy Book Candidate');
  });

  test('marks stub provider candidates clearly', () {
    final candidate = ProviderCandidate.fromJson(const {
      'provider': 'tmdb',
      'provider_item_id': 'stub-movie-matrix',
      'title': 'Matrix (TMDb stub)',
      'kind': 'movie',
    });

    expect(candidate.isStub, isTrue);
  });

  test('detects provider variant candidates', () {
    final candidate = ProviderCandidate.fromJson(const {
      'provider': 'gcd',
      'provider_item_id': '2665653',
      'title': 'Absolute Batman #1 [Jim Lee Cardstock Variant Cover]',
      'kind': 'comic',
      'summary': 'December 2024 · 5.99 USD · variant',
    });

    expect(candidate.isVariant, isTrue);
  });
}
