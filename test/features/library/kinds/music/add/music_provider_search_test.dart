import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_provider_search.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_metadata.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/transport/provider_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

const _provenance = ProviderProvenance(
  fetchedAt: '2026-09-16T00:00:00Z',
  sourceUrl: 'https://musicbrainz.org/ws/2/release',
);

void main() {
  test('release-group search exposes every typed child release', () async {
    final provider = _provider([
      _group(
        id: 'group-1',
        title: 'Kind of Blue',
        releases: const [
          MusicReleaseSummaryCandidate(
            providerItemId: 'release-1',
            title: 'Kind of Blue',
          ),
          MusicReleaseSummaryCandidate(
            providerItemId: 'release-2',
            title: 'Kind of Blue (Deluxe)',
          ),
        ],
      ),
    ]);

    final results = await searchMusicProviderCandidatesWithContext(
      provider,
      query: 'Kind of Blue',
      kind: CatalogMediaKind.music,
      limit: 25,
      context: LibraryAddSearchContext(query: 'Kind of Blue'),
    );

    expect(
      results.whereType<MusicReleaseGroupCandidate>(),
      hasLength(1),
    );
    expect(
      results.whereType<MusicReleaseCandidate>().map(
            (candidate) => candidate.providerItemId,
          ),
      containsAll(<String>['release-1', 'release-2']),
    );
  });

  test('filters broad typed Music matches by all meaningful query terms',
      () async {
    final provider = _provider([
      _release(
        id: 'unrelated-release',
        title: 'Deathosterone',
        releaseGroupId: 'unrelated-group',
        releaseGroupTitle: 'Si',
      ),
      _release(
        id: 'matching-release',
        title: 'Sarmale si Sabaton',
        artist: 'Sabaton',
        releaseGroupId: 'matching-group',
        releaseGroupTitle: 'Sarmale si Sabaton',
      ),
    ]);

    final results = await searchMusicProviderCandidates(
      provider,
      query: 'sarmale si sabaton',
      kind: CatalogMediaKind.music,
    );
    final releases = results
        .where(
          (candidate) => candidate.candidateType == musicReleaseCandidateType,
        )
        .toList(growable: false);

    expect(releases, hasLength(1));
    expect(releases.single.providerItemId, 'matching-release');
    expect(
      results.any(
        (candidate) =>
            candidate.candidateType == musicReleaseGroupCandidateType,
      ),
      isTrue,
    );
  });

  test('does not treat an artist-only partial match as a full query match',
      () async {
    final provider = _provider([
      _release(
        id: 'artist-only-match',
        title: 'Heroes',
        artist: 'Sabaton',
      ),
    ]);

    final results = await searchMusicProviderCandidates(
      provider,
      query: 'sarmale si sabaton',
      kind: CatalogMediaKind.music,
    );

    expect(results, isEmpty);
  });

  test('keeps a stop-word-only query selective', () async {
    final provider = _provider([
      _release(id: 'si-match', title: 'Si'),
      _release(id: 'other-match', title: 'The Other Album'),
    ]);

    final results = await searchMusicProviderCandidates(
      provider,
      query: 'si',
      kind: CatalogMediaKind.music,
    );

    expect(
      results.map((candidate) => candidate.providerItemId),
      contains('si-match'),
    );
    expect(
      results.map((candidate) => candidate.providerItemId),
      isNot(contains('other-match')),
    );
  });

  test('keeps artist-only typed Music queries searchable', () async {
    final provider = _provider([
      _release(
        id: 'artist-match',
        title: 'The Last Stand',
        artist: 'Sabaton',
        releaseGroupId: 'artist-group',
        releaseGroupTitle: 'The Last Stand',
      ),
    ]);

    final results = await searchMusicProviderCandidates(
      provider,
      query: 'Sabaton',
      kind: CatalogMediaKind.music,
    );

    expect(
      results.where(
        (candidate) => candidate.candidateType == musicReleaseCandidateType,
      ),
      hasLength(1),
    );
  });
}

ProviderConnector _provider(List<MusicProviderCandidate> results) {
  final capability = _FakeTypedMusicCapability(results);
  return ProviderConnector(
    id: ProviderId.musicBrainz,
    descriptor: MusicBrainzProvider.musicBrainzDescriptor,
    kindOwnedMetadata: capability,
  );
}

MusicProviderCandidate _group({
  required String id,
  required String title,
  List<MusicReleaseSummaryCandidate> releases = const [],
}) {
  return MusicReleaseGroupCandidate(
    identity: ProviderEntityIdentity(
      provider: 'musicbrainz',
      externalId: id,
      scope: LibraryEntityScope.work,
    ),
    title: title,
    releases: releases,
    provenance: _provenance,
  );
}

MusicReleaseCandidate _release({
  required String id,
  required String title,
  String? artist,
  String? releaseGroupId,
  String? releaseGroupTitle,
}) {
  return MusicReleaseCandidate(
    identity: ProviderEntityIdentity(
      provider: 'musicbrainz',
      externalId: id,
      scope: LibraryEntityScope.release,
    ),
    title: title,
    releaseGroupId: releaseGroupId,
    releaseGroupTitle: releaseGroupTitle,
    artist: artist,
    provenance: _provenance,
  );
}

final class _FakeTypedMusicCapability
    implements MusicProviderMetadataCapability {
  const _FakeTypedMusicCapability(this.results);

  final List<MusicProviderCandidate> results;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  Future<List<MusicProviderCandidate>> searchCandidates(
    String query, {
    required CatalogMediaKind kind,
    required LibraryEntityScope entityScope,
    int limit = 25,
  }) async {
    if (kind != CatalogMediaKind.music) {
      return const <MusicProviderCandidate>[];
    }
    final candidates = entityScope == LibraryEntityScope.work
        ? results.whereType<MusicReleaseGroupCandidate>()
        : results.whereType<MusicReleaseCandidate>();
    return candidates.take(limit).toList(growable: false);
  }

  @override
  Future<ProviderEnvelope<MusicProviderCandidate>> fetchCandidate(
    String providerItemId,
  ) async {
    final candidate = results.firstWhere(
      (value) => value.providerItemId == providerItemId,
    );
    return ProviderEnvelope<MusicProviderCandidate>(
      provider: candidate.provider,
      providerItemId: candidate.providerItemId,
      entityScope: candidate.entityScope,
      payload: candidate,
      provenance: candidate.provenance,
      attribution: const ProviderAttribution(required: true),
    );
  }
}
