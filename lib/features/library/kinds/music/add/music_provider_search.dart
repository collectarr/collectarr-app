import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_search_filters.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_preview_mapper.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/runtime/provider_runtime.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

Future<LibraryAddProviderCandidatePreview?> loadMusicProviderCandidatePreview(
  ProviderConnector provider,
  ProviderSearchCandidate candidate,
) async {
  final typedMetadata = provider.typedMetadata;
  if (typedMetadata is! MusicProviderMetadataCapability ||
      candidate is! MusicReleaseCandidate) {
    return null;
  }
  if (candidate.isHydrated) {
    return LibraryAddProviderCandidatePreview(
      candidate: candidate,
      preview: providerPreviewFromMusicReleaseCandidate(candidate),
    );
  }

  final envelope = await typedMetadata.fetchCandidate(candidate.providerItemId);
  final hydrated = envelope.payload;
  if (hydrated is MusicReleaseCandidate) {
    return LibraryAddProviderCandidatePreview(
      candidate: hydrated,
      preview: providerPreviewFromMusicReleaseCandidate(hydrated),
    );
  }
  return LibraryAddProviderCandidatePreview(
    candidate: candidate,
    preview: providerPreviewFromMusicReleaseCandidate(candidate),
  );
}

/// Searches Music providers for concrete releases, the catalog unit selected
/// by the Add flow. Release groups remain provider metadata used for
/// attribution, but are never emitted as selectable Add results.
Future<List<ProviderSearchCandidate>> searchMusicProviderCandidatesWithContext(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  required int limit,
  required LibraryAddSearchContext context,
  ProviderCancellationToken? cancellationToken,
}) async {
  if (kind != CatalogMediaKind.music) {
    return const <ProviderSearchCandidate>[];
  }
  final typedMetadata = provider.typedMetadata;
  if (typedMetadata is! MusicProviderMetadataCapability) {
    return const <ProviderSearchCandidate>[];
  }

  final typedResults = await typedMetadata.searchCandidates(
    query,
    kind: CatalogMediaKind.music,
    limit: limit,
    cancellationToken: cancellationToken,
  );
  final localMatchQuery = [
    context.query,
    context.textValueFor(musicAddArtistFilterId),
  ].where((value) => value.trim().isNotEmpty).join(' ');
  final seenReleaseIds = <String>{};
  return [
    for (final candidate in typedResults)
      if (candidate is MusicReleaseCandidate &&
          _matchesMusicCandidate(candidate, localMatchQuery) &&
          musicAddProviderCandidateMatchesMedium(candidate, context) &&
          seenReleaseIds.add(candidate.providerItemId))
        candidate,
  ];
}

/// Searches and returns one typed candidate per concrete Music release.
Future<List<ProviderSearchCandidate>> searchMusicProviderCandidates(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  int limit = 25,
  String? matchQuery,
  ProviderCancellationToken? cancellationToken,
}) async {
  if (kind != CatalogMediaKind.music) {
    return const <ProviderSearchCandidate>[];
  }
  final typedMetadata = provider.typedMetadata;
  if (typedMetadata is! MusicProviderMetadataCapability) {
    return const <ProviderSearchCandidate>[];
  }

  final typedResults = await typedMetadata.searchCandidates(
    query,
    kind: CatalogMediaKind.music,
    limit: limit,
    cancellationToken: cancellationToken,
  );
  final seenReleaseIds = <String>{};
  return [
    for (final candidate in typedResults)
      if (candidate is MusicReleaseCandidate &&
          _matchesMusicCandidate(candidate, matchQuery ?? query) &&
          seenReleaseIds.add(candidate.providerItemId))
        candidate,
  ];
}

bool _matchesMusicCandidate(MusicReleaseCandidate candidate, String query) {
  final tokens = _musicSearchTokens(_stripMusicSearchOperators(query));
  if (tokens.isEmpty) return true;
  final searchableText =
      [candidate.title, candidate.artist].whereType<String>().join(' ');
  final searchableTokens = _musicSearchTokens(
    searchableText,
    ignoreStopWords: false,
  ).toSet();
  return tokens.every(searchableTokens.contains);
}

String _stripMusicSearchOperators(String value) => value
    .replaceAllMapped(
      RegExp(r'\b[a-z-]+:"([^"]*)"'),
      (match) => match.group(1) ?? '',
    )
    .replaceAllMapped(
      RegExp(r'\b[a-z-]+:([^\s]+)'),
      (match) => match.group(1) ?? '',
    )
    .replaceAll('"', '');

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
      .where((token) =>
          token.length > 1 &&
          (!ignoreStopWords || !_musicSearchStopWords.contains(token)))
      .toSet()
      .toList(growable: false);
  if (meaningful.isNotEmpty || !ignoreStopWords) return meaningful;

  // Keep short stop-word-only searches selective.
  return tokens.where((token) => token.length > 1).toSet().toList();
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
