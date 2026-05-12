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

  test('defaults kind for older provider responses', () {
    final candidate = ProviderCandidate.fromJson(const {
      'provider': 'comicvine',
      'provider_item_id': '4000-legacy',
      'title': 'Legacy Candidate',
    });

    expect(candidate.kind, 'comic');
    expect(candidate.placeholderCatalogItem().id, '4000-legacy');
    expect(candidate.placeholderCatalogItem().kind, 'comic');
    expect(candidate.placeholderCatalogItem().title, 'Legacy Candidate');
  });
}
