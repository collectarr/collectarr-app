import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
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
    // MusicBrainz uses Lucene's broad field search. Short connector words
    // such as "si" can therefore produce unrelated releases whose artist or
    // title happens to contain that token. Keep provider search broad at the
    // transport boundary, but enforce that every meaningful query token is
    // represented by the release, artist, or release-group title before it
    // becomes an actionable Music candidate.
    if (!_matchesMusicQuery(result, query)) {
      continue;
    }
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
          artist: candidate.artist,
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

bool _matchesMusicQuery(ProviderSearchResult result, String query) {
  final queryTokens = _musicSearchTokens(query);
  if (queryTokens.isEmpty) return true;

  final searchableText = [
    result.title,
    result.artist,
    result.parent?.title,
  ].whereType<String>().join(' ');
  // Keep stop-word handling asymmetric: connector words can be omitted from
  // a multi-word query, but a query made only of one of those words is still
  // a real search and must not return every provider result.
  final searchableTokens = _musicSearchTokens(
    searchableText,
    ignoreStopWords: false,
  ).toSet();
  return queryTokens.every(searchableTokens.contains);
}

List<String> _musicSearchTokens(
  String value, {
  bool ignoreStopWords = true,
}) {
  final normalized = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (normalized.isEmpty) return const <String>[];

  final tokens = normalized.split(' ');
  final meaningful = tokens
      .where((token) {
        if (token.length <= 1) return false;
        return !ignoreStopWords || !_musicSearchStopWords.contains(token);
      })
      .toSet()
      .toList(growable: false);
  if (meaningful.isNotEmpty || !ignoreStopWords) return meaningful;

  // A query such as "si" must remain selective rather than turning into an
  // empty query after stop-word removal.
  return tokens
      .where((token) => token.length > 1)
      .toSet()
      .toList(growable: false);
}

const _musicSearchStopWords = <String>{
  'a',
  'al',
  'and',
  'cu',
  'de',
  'din',
  'in',
  'la',
  'of',
  'or',
  'si',
  'the',
};
