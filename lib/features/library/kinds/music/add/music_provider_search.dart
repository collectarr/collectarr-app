import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_result_policy.dart';

/// Converts Music provider search results into a nested group/release list.
///
/// The synthetic parent candidate is intentionally preview-only. A concrete
/// MusicRelease remains the actionable selection because Core ingests the
/// release provider ID and resolves its release-group relationship itself.
Future<List<ProviderCandidate>> searchMusicProviderCandidates(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  int limit = 25,
}) async {
  final results = await provider.search(query, kind: kind, limit: limit);
  final groups = <String, ProviderCandidate>{};
  final releases = <ProviderCandidate>[];
  final supportsReleaseGroupPreview = provider.descriptor.name ==
      MusicBrainzProvider.musicBrainzDescriptor.name;

  for (final result in results) {
    if (result.kind != kind || result.providerItemId.trim().isEmpty) {
      continue;
    }
    final candidate = ProviderCandidate.fromSearchResult(
      result,
      provider: provider.descriptor.name,
    );
    final parent = candidate.parent;
    if (supportsReleaseGroupPreview && parent != null && parent.isValid) {
      groups.putIfAbsent(
        parent.id,
        () => ProviderCandidate(
          provider: candidate.provider,
          providerItemId:
              MusicBrainzProvider.releaseGroupProviderItemId(parent.id),
          title: parent.title,
          kind: CatalogMediaKind.music,
          summary: candidate.summary,
          imageUrl: candidate.imageUrl,
          candidateType: musicReleaseGroupCandidateType,
          parent: parent,
          previewOnly: true,
        ),
      );
    }
    releases.add(candidate);
  }

  return [
    ...groups.values,
    ...releases,
  ];
}
