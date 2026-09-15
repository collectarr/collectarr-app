import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_search_filters.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music search defaults to release-group scope', () {
    final context = LibraryAddSearchContext(query: 'Pink Floyd');

    expect(
      musicAddSearchScopeFor(context),
      MusicAddSearchScope.releaseGroup,
    );
    expect(musicAddMediumFilterFor(context), MusicAddMediumFilter.all);
    expect(musicAddHasSearchInput(context), isTrue);
  });

  test('medium filter classifies concrete provider releases', () {
    final cdContext = LibraryAddSearchContext(
      advancedFilters: {
        musicAddMediumFilterId: MusicAddMediumFilter.cd.value,
      },
    );
    final vinylContext = LibraryAddSearchContext(
      advancedFilters: {
        musicAddMediumFilterId: MusicAddMediumFilter.vinyl.value,
      },
    );
    const cd = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-cd',
      title: 'Album',
      kind: CatalogMediaKind.music,
      mediumTypes: ['Compact Disc'],
    );
    const vinyl = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-vinyl',
      title: 'Album',
      kind: CatalogMediaKind.music,
      mediumTypes: ['Vinyl'],
    );

    expect(musicAddProviderCandidateMatchesMedium(cd, cdContext), isTrue);
    expect(musicAddProviderCandidateMatchesMedium(vinyl, cdContext), isFalse);
    expect(
      musicAddProviderCandidateMatchesMedium(vinyl, vinylContext),
      isTrue,
    );
  });

  test('unknown release-group nodes survive until their children hydrate', () {
    final context = LibraryAddSearchContext(
      advancedFilters: {
        musicAddMediumFilterId: MusicAddMediumFilter.digital.value,
      },
    );
    const group = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-group:group-1',
      title: 'Album',
      kind: CatalogMediaKind.music,
      candidateType: 'release_group',
      previewOnly: true,
    );

    expect(musicAddProviderCandidateMatchesMedium(group, context), isTrue);
  });
}
