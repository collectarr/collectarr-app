import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_provider_search.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_parent_hint.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters broad MusicBrainz matches by all meaningful query terms',
      () async {
    final provider = ProviderConnector(
      id: ProviderId.musicBrainz,
      descriptor: MusicBrainzProvider.musicBrainzDescriptor,
      metadata: _FakeMetadataCapability([
        const ProviderSearchResult(
          provider: 'musicbrainz',
          providerItemId: 'unrelated-release',
          title: 'Deathosterone',
          kind: CatalogMediaKind.music,
          candidateType: musicReleaseCandidateType,
          summary: 'Si · 2014-01-01 · FR',
          parent: ProviderSearchParentHint(id: 'unrelated-group', title: 'Si'),
        ),
        const ProviderSearchResult(
          provider: 'musicbrainz',
          providerItemId: 'matching-release',
          title: 'Sarmale si Sabaton',
          kind: CatalogMediaKind.music,
          candidateType: musicReleaseCandidateType,
          artist: 'Sabaton',
          summary: 'Sabaton · 2025-12-08 · RO',
          parent: ProviderSearchParentHint(
            id: 'matching-group',
            title: 'Sarmale si Sabaton',
          ),
        ),
      ]),
    );

    final results = await searchMusicProviderCandidates(
      provider,
      query: 'sarmale si sabaton',
      kind: CatalogMediaKind.music,
    );
    final releases = results
        .where(
            (candidate) => candidate.candidateType == musicReleaseCandidateType)
        .toList(growable: false);

    expect(releases, hasLength(1));
    expect(releases.single.providerItemId, 'matching-release');
    expect(
        results.any(
          (candidate) =>
              candidate.candidateType == musicReleaseGroupCandidateType,
        ),
        isTrue);
  });

  test('does not treat an artist-only partial match as a full query match',
      () async {
    final provider = ProviderConnector(
      id: ProviderId.musicBrainz,
      descriptor: MusicBrainzProvider.musicBrainzDescriptor,
      metadata: _FakeMetadataCapability([
        const ProviderSearchResult(
          provider: 'musicbrainz',
          providerItemId: 'artist-only-match',
          title: 'Heroes',
          kind: CatalogMediaKind.music,
          candidateType: musicReleaseCandidateType,
          artist: 'Sabaton',
        ),
      ]),
    );

    final results = await searchMusicProviderCandidates(
      provider,
      query: 'sarmale si sabaton',
      kind: CatalogMediaKind.music,
    );

    expect(results, isEmpty);
  });

  test('keeps a stop-word-only query selective', () async {
    final provider = ProviderConnector(
      id: ProviderId.musicBrainz,
      descriptor: MusicBrainzProvider.musicBrainzDescriptor,
      metadata: _FakeMetadataCapability([
        const ProviderSearchResult(
          provider: 'musicbrainz',
          providerItemId: 'si-match',
          title: 'Si',
          kind: CatalogMediaKind.music,
          candidateType: musicReleaseCandidateType,
        ),
        const ProviderSearchResult(
          provider: 'musicbrainz',
          providerItemId: 'other-match',
          title: 'The Other Album',
          kind: CatalogMediaKind.music,
          candidateType: musicReleaseCandidateType,
        ),
      ]),
    );

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

  test('keeps artist-only MusicBrainz queries searchable', () async {
    final provider = ProviderConnector(
      id: ProviderId.musicBrainz,
      descriptor: MusicBrainzProvider.musicBrainzDescriptor,
      metadata: _FakeMetadataCapability([
        const ProviderSearchResult(
          provider: 'musicbrainz',
          providerItemId: 'artist-match',
          title: 'The Last Stand',
          kind: CatalogMediaKind.music,
          candidateType: musicReleaseCandidateType,
          artist: 'Sabaton',
          summary: 'Sabaton · 2016-08-19 · SE',
          parent: ProviderSearchParentHint(
            id: 'artist-group',
            title: 'The Last Stand',
          ),
        ),
      ]),
    );

    final results = await searchMusicProviderCandidates(
      provider,
      query: 'Sabaton',
      kind: CatalogMediaKind.music,
    );

    expect(
      results.where(
          (candidate) => candidate.candidateType == musicReleaseCandidateType),
      hasLength(1),
    );
  });
}

final class _FakeMetadataCapability implements MetadataCapability {
  const _FakeMetadataCapability(this.results);

  final List<ProviderSearchResult> results;

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    CatalogMediaKind? kind,
    int limit = 25,
  }) async {
    return results;
  }

  @override
  Future<ProviderMetadataEnvelope> fetchItem(
    String providerItemId, {
    CatalogMediaKind? kind,
  }) {
    throw UnimplementedError();
  }
}
