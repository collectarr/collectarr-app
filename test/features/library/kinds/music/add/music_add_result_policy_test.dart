import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_search_unified.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_provider_candidate_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';
import 'package:flutter_test/flutter_test.dart';

const _provenance = ProviderProvenance(fetchedAt: '2026-09-16T00:00:00Z');

MusicReleaseCandidate _release(
  String id, {
  String title = 'Kind of Blue',
  String? groupId = 'group-1',
  String? artist = 'Miles Davis',
}) {
  return MusicReleaseCandidate(
    identity: ProviderEntityIdentity(
      provider: 'musicbrainz',
      externalId: id,
      scope: LibraryEntityScope.release,
    ),
    title: title,
    releaseGroupId: groupId,
    releaseGroupTitle: groupId == null ? null : 'Kind of Blue',
    artist: artist,
    provenance: _provenance,
  );
}

MusicReleaseGroupCandidate _group({
  List<MusicReleaseSummaryCandidate> releases = const [],
}) {
  return MusicReleaseGroupCandidate(
    identity: const ProviderEntityIdentity(
      provider: 'musicbrainz',
      externalId: 'group-1',
      scope: LibraryEntityScope.work,
    ),
    title: 'Kind of Blue',
    artist: 'Miles Davis',
    releases: releases,
    provenance: _provenance,
  );
}

void main() {
  test('Music policy nests typed releases below their release group', () {
    final groupCandidate = _group();
    final releaseA = _release('release-1');
    final releaseB = _release(
      'release-2',
      title: 'Kind of Blue (Reissue)',
    );

    final groups = buildUnifiedGroups(
      coreResults: const [],
      providerResults: [groupCandidate, releaseA, releaseB],
      resultPolicy: musicAddResultPolicy,
    );

    expect(groups, hasLength(1));
    expect(groups.single.title, 'Kind of Blue');
    expect(groups.single.artist, 'Miles Davis');
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
    expect(musicAddResultPolicy.isProviderGroupCandidate(releaseA), isFalse);
  });

  test(
      'typed Music group projection keeps the canonical group without a fake release',
      () {
    final projected = musicCatalogTransportFromTypedProviderCandidate(
      _group(),
    );
    final group = projected.kindCapability
        .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);

    expect(group.id.value, 'musicbrainz:group-1');
    expect(group.title, 'Kind of Blue');
    expect(group.releases, isEmpty);
  });

  test('provider groups with the same title keep distinct release groups', () {
    final releaseA = _release('release-a', groupId: 'group-a');
    final releaseB = _release('release-b', groupId: 'group-b');

    final groups = buildUnifiedGroups(
      coreResults: const [],
      providerResults: [releaseA, releaseB],
      resultPolicy: musicAddResultPolicy,
    );

    expect(groups, hasLength(2));
    expect(
      groups.map((group) => group.providerItems.single),
      containsAll([releaseA, releaseB]),
    );
  });

  test('typed Music group previews project every release as a concrete child',
      () {
    final groupCandidate = _group();
    const preview = AdminProviderPreview(
      provider: 'musicbrainz',
      providerItemId: 'release-group:group-1',
      kind: 'music',
      title: 'Kind of Blue',
      music: {
        'artist': 'Miles Davis',
        'releases': [
          {
            'id': 'release-1',
            'title': 'Kind of Blue',
            'release_date': '1959-08-17',
            'country_code': 'US',
            'packaging': 'Jewel Case',
          },
          {
            'id': 'release-2',
            'title': 'Kind of Blue',
            'release_date': '2015-04-21',
            'country_code': 'EU',
          },
        ],
      },
    );

    final children = const MusicLibraryMediaPresentationBuilder()
        .buildProviderGroupPreviewChildrenForSearchCandidate(
      groupCandidate: groupCandidate,
      preview: preview,
    );

    expect(children.map((candidate) => candidate.providerItemId), [
      'release-1',
      'release-2',
    ]);
    expect(
      children.every(
        (candidate) => candidate.searchRole == ProviderSearchRole.release,
      ),
      isTrue,
    );
    expect(
      children.every((candidate) => candidate.parent == groupCandidate.parent),
      isTrue,
    );
    expect(children.first.summary, 'Miles Davis / 1959-08-17 / US');
  });
}
