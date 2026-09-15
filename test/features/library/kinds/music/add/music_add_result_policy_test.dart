import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_unified.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_provider_candidate_projection.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_parent_hint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music policy nests releases below their release group', () {
    const parent = ProviderSearchParentHint(
      id: 'group-1',
      title: 'Kind of Blue',
    );
    const groupCandidate = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-group:group-1',
      title: 'Kind of Blue',
      kind: CatalogMediaKind.music,
      candidateType: musicReleaseGroupCandidateType,
      parent: parent,
      previewOnly: true,
    );
    const releaseA = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-1',
      title: 'Kind of Blue',
      kind: CatalogMediaKind.music,
      candidateType: musicReleaseCandidateType,
      parent: parent,
    );
    const releaseB = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-2',
      title: 'Kind of Blue (Reissue)',
      kind: CatalogMediaKind.music,
      candidateType: musicReleaseCandidateType,
      parent: parent,
    );

    final groups = buildUnifiedGroups(
      coreResults: const [],
      providerResults: [groupCandidate, releaseA, releaseB],
      resultPolicy: musicAddResultPolicy,
    );

    expect(groups, hasLength(1));
    expect(groups.single.title, 'Kind of Blue');
    expect(groups.single.groupCandidate, groupCandidate);
    expect(groups.single.groupCandidateLabel, 'Kind of Blue (release group)');
    expect(groups.single.groupCandidateBadge, 'release group');
    expect(groups.single.showGroupCandidateAsChild, isFalse);
    expect(groups.single.providerItems, [releaseA, releaseB]);
    expect(
      musicAddResultPolicy.providerGroupTitle(releaseA),
      'Kind of Blue',
    );
    expect(
      musicAddResultPolicy.isProviderGroupCandidate(groupCandidate),
      isTrue,
    );
    expect(
      musicAddResultPolicy.isProviderGroupCandidate(releaseA),
      isFalse,
    );
  });

  test('parent hints remain structural and round-trip through candidates', () {
    final candidate = ProviderCandidate.fromJson(const {
      'provider': 'musicbrainz',
      'provider_item_id': 'release-1',
      'title': 'Kind of Blue',
      'kind': 'music',
      'candidate_type': 'release',
      'parent': {
        'id': 'group-1',
        'title': 'Kind of Blue',
      },
    });

    expect(candidate.parent?.id, 'group-1');
    expect(candidate.parent?.title, 'Kind of Blue');
    expect(candidate.candidateType, musicReleaseCandidateType);
  });

  test(
      'provider group projection keeps the canonical group without a fake release',
      () {
    const groupCandidate = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-group:group-1',
      title: 'Kind of Blue',
      kind: CatalogMediaKind.music,
      candidateType: musicReleaseGroupCandidateType,
      parent: ProviderSearchParentHint(id: 'group-1', title: 'Kind of Blue'),
      previewOnly: true,
    );

    final projected =
        musicCatalogTransportFromProviderCandidate(groupCandidate);
    final group =
        projected.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);

    expect(group.id.value, 'group-1');
    expect(group.title, 'Kind of Blue');
    expect(group.releases, isEmpty);
  });

  test('provider groups with the same title keep distinct release groups', () {
    const parentA = ProviderSearchParentHint(id: 'group-a', title: 'Album');
    const parentB = ProviderSearchParentHint(id: 'group-b', title: 'Album');
    const releaseA = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-a',
      title: 'Album',
      kind: CatalogMediaKind.music,
      candidateType: musicReleaseCandidateType,
      parent: parentA,
    );
    const releaseB = ProviderCandidate(
      provider: 'musicbrainz',
      providerItemId: 'release-b',
      title: 'Album',
      kind: CatalogMediaKind.music,
      candidateType: musicReleaseCandidateType,
      parent: parentB,
    );

    final groups = buildUnifiedGroups(
      coreResults: const [],
      providerResults: [releaseA, releaseB],
      resultPolicy: musicAddResultPolicy,
    );

    expect(groups, hasLength(2));
    expect(groups.map((group) => group.providerItems.single),
        containsAll([releaseA, releaseB]));
  });
}
