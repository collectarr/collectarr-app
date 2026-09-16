import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_provider_search.dart';
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
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:flutter_test/flutter_test.dart';

const _provenance = ProviderProvenance(
  fetchedAt: '2026-09-16T00:00:00Z',
  sourceUrl: 'https://musicbrainz.org/ws/2/release',
);

void main() {
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

ProviderConnector _provider(List<MusicReleaseCandidate> results) {
  final capability = _FakeTypedMusicCapability(results);
  return ProviderConnector(
    id: ProviderId.musicBrainz,
    descriptor: MusicBrainzProvider.musicBrainzDescriptor,
    metadata: capability,
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
    implements MetadataCapability, MusicProviderMetadataCapability {
  const _FakeTypedMusicCapability(this.results);

  final List<MusicReleaseCandidate> results;

  @override
  Future<List<MusicProviderCandidate>> searchCandidates(
    String query, {
    required CatalogMediaKind kind,
    required LibraryEntityScope entityScope,
    int limit = 25,
  }) async {
    if (kind != CatalogMediaKind.music ||
        entityScope == LibraryEntityScope.work) {
      return const <MusicProviderCandidate>[];
    }
    return results.take(limit).toList(growable: false);
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

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    CatalogMediaKind? kind,
    int limit = 25,
  }) async =>
      const <ProviderSearchResult>[];

  @override
  Future<ProviderMetadataEnvelope> fetchItem(
    String providerItemId, {
    CatalogMediaKind? kind,
  }) {
    throw UnimplementedError();
  }
}
