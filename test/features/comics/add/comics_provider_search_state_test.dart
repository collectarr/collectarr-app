import 'package:collectarr_app/features/comics/add/comics_provider_search_state.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider search state tracks search lifecycle and selection', () {
    final initial = ComicsProviderSearchState.initial('gcd');

    final searching = initial.startSearch();
    expect(searching.provider, 'gcd');
    expect(searching.searched, isTrue);
    expect(searching.isSearching, isTrue);
    expect(searching.results, isEmpty);

    final withResults = searching.withResults([
      _candidate('gcd-1'),
      _candidate('gcd-2'),
    ]);
    expect(withResults.isSearching, isFalse);
    expect(withResults.selectedCandidate?.providerItemId, 'gcd-1');

    final selected = withResults.select('gcd-2');
    expect(selected.selectedCandidate?.title, 'Batman gcd-2');

    final changed = selected.changeProvider('comicvine');
    expect(changed.provider, 'comicvine');
    expect(changed.results, isEmpty);
    expect(changed.searched, isFalse);
  });
}

ProviderCandidate _candidate(String id) {
  return ProviderCandidate(
    provider: 'gcd',
    providerItemId: id,
    title: 'Batman $id',
    kind: 'comic',
  );
}
