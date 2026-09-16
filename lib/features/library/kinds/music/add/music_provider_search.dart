import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_search_filters.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_preview_mapper.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

Future<LibraryAddProviderCandidatePreview?> loadMusicProviderCandidatePreview(
  ProviderConnector provider,
  ProviderSearchCandidate candidate,
) async {
  final typedMetadata = provider.metadata;
  if (typedMetadata is! MusicProviderMetadataCapability) {
    return null;
  }
  final musicMetadata = typedMetadata as MusicProviderMetadataCapability;
  if (candidate case final MusicReleaseCandidate release) {
    if (release.isHydrated) {
      return LibraryAddProviderCandidatePreview(
        candidate: candidate,
        preview: providerPreviewFromMusicReleaseCandidate(release),
      );
    }
    final envelope = await musicMetadata.fetchCandidate(release.providerItemId);
    final hydrated = envelope.payload;
    if (hydrated is MusicReleaseCandidate) {
      return LibraryAddProviderCandidatePreview(
        candidate: hydrated,
        preview: providerPreviewFromMusicReleaseCandidate(hydrated),
      );
    }
    return LibraryAddProviderCandidatePreview(
      candidate: candidate,
      preview: providerPreviewFromMusicReleaseCandidate(release),
    );
  }
  if (candidate case final MusicReleaseGroupCandidate group) {
    final envelope = await musicMetadata.fetchCandidate(group.providerItemId);
    final hydrated = envelope.payload;
    if (hydrated is MusicReleaseGroupCandidate) {
      return LibraryAddProviderCandidatePreview(
        candidate: hydrated,
        preview: providerPreviewFromMusicReleaseGroupCandidate(hydrated),
      );
    }
    return LibraryAddProviderCandidatePreview(
      candidate: candidate,
      preview: providerPreviewFromMusicReleaseGroupCandidate(group),
    );
  }
  return null;
}

/// Routes Music search through the provider's typed candidate capability.
/// Music never reconstructs a candidate from the erased ProviderSearchResult
/// transport.
Future<List<ProviderSearchCandidate>> searchMusicProviderCandidatesWithContext(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  required int limit,
  required LibraryAddSearchContext context,
}) async {
  if (kind != CatalogMediaKind.music) {
    return const <ProviderSearchCandidate>[];
  }
  final typedMetadata = provider.metadata;
  if (typedMetadata is! MusicProviderMetadataCapability) {
    return const <ProviderSearchCandidate>[];
  }
  final musicMetadata = typedMetadata as MusicProviderMetadataCapability;

  final releaseGroupSearch =
      musicAddSearchScopeFor(context) == MusicAddSearchScope.releaseGroup &&
          musicAddProviderMediumQuery(context) == null &&
          context.identifierCode.trim().isEmpty;
  final searchQuery = releaseGroupSearch
      ? _musicReleaseGroupQuery(context, fallback: query)
      : query;
  final typedResults = await musicMetadata.searchCandidates(
    searchQuery,
    kind: CatalogMediaKind.music,
    entityScope: releaseGroupSearch
        ? LibraryEntityScope.work
        : LibraryEntityScope.release,
    limit: limit,
  );
  final matchQuery = query.replaceAll(RegExp(r'\bformat:\S+'), '').trim();

  if (releaseGroupSearch) {
    return [
      for (final result in typedResults)
        if (result case final MusicReleaseGroupCandidate group)
          if (_matchesMusicCandidate(group, matchQuery)) group,
    ];
  }
  final grouped = _groupReleaseCandidates(
    typedResults.whereType<MusicReleaseCandidate>(),
    matchQuery: matchQuery,
  );
  return grouped;
}

String _musicReleaseGroupQuery(
  LibraryAddSearchContext context, {
  required String fallback,
}) {
  final title = context.query.trim();
  final artist = context.textValueFor(musicAddArtistFilterId);
  final year = context.textValueFor(musicAddYearFilterId);
  final query = buildLibraryAddSearchQuery([
    if (title.isNotEmpty) 'releasegroup:"${title.replaceAll('"', '')}"',
    if (artist.isNotEmpty) 'artist:"${artist.replaceAll('"', '')}"',
    if (year.isNotEmpty) 'firstreleasedate:${year.replaceAll(' ', '')}*',
  ]);
  return query.isEmpty ? fallback : query;
}

/// Searches only the typed Music release boundary, then builds a typed Work
/// candidate from the concrete releases so the UI can render one group with
/// exactly the releases returned by the provider.
Future<List<ProviderSearchCandidate>> searchMusicProviderCandidates(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  int limit = 25,
  String? matchQuery,
}) async {
  if (kind != CatalogMediaKind.music) {
    return const <ProviderSearchCandidate>[];
  }
  final typedMetadata = provider.metadata;
  if (typedMetadata is! MusicProviderMetadataCapability) {
    return const <ProviderSearchCandidate>[];
  }
  final musicMetadata = typedMetadata as MusicProviderMetadataCapability;
  final typedResults = await musicMetadata.searchCandidates(
    query,
    kind: CatalogMediaKind.music,
    entityScope: LibraryEntityScope.release,
    limit: limit,
  );
  return _groupReleaseCandidates(
    typedResults.whereType<MusicReleaseCandidate>(),
    matchQuery: matchQuery ?? query,
  );
}

List<ProviderSearchCandidate> _groupReleaseCandidates(
  Iterable<MusicReleaseCandidate> source, {
  required String matchQuery,
}) {
  final groups = <String, List<MusicReleaseSummaryCandidate>>{};
  final groupTitles = <String, String>{};
  final groupArtists = <String, String?>{};
  final releases = <MusicReleaseCandidate>[];
  final releaseIds = <String>{};

  for (final candidate in source) {
    if (!_matchesMusicCandidate(candidate, matchQuery)) continue;
    if (!releaseIds.add(candidate.providerItemId)) continue;

    final parentId = candidate.releaseGroupId?.trim();
    if (parentId != null && parentId.isNotEmpty) {
      final summaries = groups.putIfAbsent(
        parentId,
        () => <MusicReleaseSummaryCandidate>[],
      );
      if (!summaries.any(
        (release) => release.providerItemId == candidate.providerItemId,
      )) {
        summaries.add(_summaryFromRelease(candidate));
      }
      groupTitles.putIfAbsent(
        parentId,
        () => candidate.releaseGroupTitle ?? candidate.title,
      );
      groupArtists.putIfAbsent(parentId, () => candidate.artist);
    }
    releases.add(candidate);
  }

  final groupCandidates = [
    for (final entry in groups.entries)
      if (entry.value.isNotEmpty)
        MusicReleaseGroupCandidate(
          identity: ProviderEntityIdentity(
            provider: releases.first.identity.provider,
            externalId: entry.key,
            scope: LibraryEntityScope.work,
          ),
          title: groupTitles[entry.key] ?? entry.key,
          artist: groupArtists[entry.key],
          releases: entry.value,
          provenance: releases.first.provenance,
        ),
  ];
  return [...groupCandidates, ...releases];
}

MusicReleaseSummaryCandidate _summaryFromRelease(MusicReleaseCandidate value) {
  final format = value.mediums
      .map((medium) => medium.format)
      .whereType<String>()
      .map((format) => format.trim())
      .firstWhere((format) => format.isNotEmpty, orElse: () => '');
  return MusicReleaseSummaryCandidate(
    providerItemId: value.providerItemId,
    title: value.title,
    releaseDate: value.releaseDate,
    country: value.country,
    status: value.releaseStatus,
    packaging: value.packaging,
    format: format.isEmpty ? null : format,
    publisher: value.publisher,
    catalogNumber: value.catalogNumber,
    barcode: value.barcode,
  );
}

bool _matchesMusicCandidate(ProviderSearchCandidate result, String query) {
  final queryTokens = _musicSearchTokens(_stripMusicSearchOperators(query));
  if (queryTokens.isEmpty) return true;
  final searchableText = [
    result.title,
    if (result case final MusicReleaseCandidate release) release.artist,
    if (result case final MusicReleaseGroupCandidate group) group.artist,
  ].whereType<String>().join(' ');
  final searchableTokens = _musicSearchTokens(
    searchableText,
    ignoreStopWords: false,
  ).toSet();
  return queryTokens.every(searchableTokens.contains);
}

String _stripMusicSearchOperators(String value) {
  return value
      .replaceAllMapped(
        RegExp(r'\b[a-z-]+:"([^"]*)"'),
        (match) => match.group(1) ?? '',
      )
      .replaceAllMapped(
        RegExp(r'\b[a-z-]+:([^\s]+)'),
        (match) => match.group(1) ?? '',
      )
      .replaceAll('"', '');
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
