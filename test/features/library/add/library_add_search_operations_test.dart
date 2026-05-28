import 'package:collectarr_app/features/library/add/library_add_search_operations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider query trims blanks and deduplicates case-insensitively', () {
    final query = buildLibraryAddProviderQuery([
      ' Batman ',
      '',
      '423',
      'batman',
      ' DC ',
      '423',
    ]);

    expect(query, 'Batman 423 DC');
  });

  test('provider debounce skips repeated signature within debounce window', () {
    final decision = evaluateLibraryAddProviderSearchDebounce(
      provider: 'comicvine',
      query: 'Batman 423',
      debounce: const Duration(milliseconds: 500),
      now: DateTime(2025, 1, 1, 12, 0, 0, 200),
      previousSignature: 'comicvine|batman 423',
      previousAt: DateTime(2025, 1, 1, 12, 0, 0),
    );

    expect(decision.shouldSkip, isTrue);
    expect(decision.signature, 'comicvine|batman 423');
  });

  test('provider debounce allows new signature or expired debounce window', () {
    final changedQueryDecision = evaluateLibraryAddProviderSearchDebounce(
      provider: 'comicvine',
      query: 'Batman 424',
      debounce: const Duration(milliseconds: 500),
      now: DateTime(2025, 1, 1, 12, 0, 0, 200),
      previousSignature: 'comicvine|batman 423',
      previousAt: DateTime(2025, 1, 1, 12, 0, 0),
    );
    final expiredDecision = evaluateLibraryAddProviderSearchDebounce(
      provider: 'comicvine',
      query: 'Batman 423',
      debounce: const Duration(milliseconds: 500),
      now: DateTime(2025, 1, 1, 12, 0, 1),
      previousSignature: 'comicvine|batman 423',
      previousAt: DateTime(2025, 1, 1, 12, 0, 0),
    );

    expect(changedQueryDecision.shouldSkip, isFalse);
    expect(expiredDecision.shouldSkip, isFalse);
  });
}