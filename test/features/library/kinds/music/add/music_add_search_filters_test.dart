import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_search_filters.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music search uses the default scope and optional medium filter', () {
    final context = LibraryAddSearchContext(query: 'Pink Floyd');

    expect(musicAddMediumFilterFor(context), MusicAddMediumFilter.all);
    expect(musicAddHasSearchInput(context), isTrue);

    final noQuery = LibraryAddSearchContext();
    expect(musicAddHasSearchInput(noQuery), isFalse);

    final filtered = LibraryAddSearchContext(
      advancedFilters: {
        musicAddMediumFilterId: MusicAddMediumFilter.vinyl.value,
      },
    );
    expect(musicAddHasSearchInput(filtered), isTrue);
    expect(musicAddProviderMediumQuery(filtered), 'format:Vinyl');
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
    const cd = MusicReleaseCandidate(
      identity: ProviderEntityIdentity(
        provider: 'musicbrainz',
        externalId: 'release-cd',
        scope: LibraryEntityScope.release,
      ),
      title: 'Album',
      releaseGroupId: 'group-1',
      mediums: [MusicMediumCandidate(mediumNumber: 1, format: 'Compact Disc')],
      provenance: ProviderProvenance(fetchedAt: '2026-09-16T00:00:00Z'),
    );
    const vinyl = MusicReleaseCandidate(
      identity: ProviderEntityIdentity(
        provider: 'musicbrainz',
        externalId: 'release-vinyl',
        scope: LibraryEntityScope.release,
      ),
      title: 'Album',
      releaseGroupId: 'group-1',
      mediums: [MusicMediumCandidate(mediumNumber: 1, format: 'Vinyl')],
      provenance: ProviderProvenance(fetchedAt: '2026-09-16T00:00:00Z'),
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
    const group = MusicReleaseGroupCandidate(
      identity: ProviderEntityIdentity(
        provider: 'musicbrainz',
        externalId: 'group-1',
        scope: LibraryEntityScope.work,
      ),
      title: 'Album',
      provenance: ProviderProvenance(fetchedAt: '2026-09-16T00:00:00Z'),
    );

    expect(musicAddProviderCandidateMatchesMedium(group, context), isTrue);
  });
}
