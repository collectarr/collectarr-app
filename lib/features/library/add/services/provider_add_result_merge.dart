import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_comparisons.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

LibraryMetadataItem mergeProviderAddResult({
  required LibraryMetadataItem ingested,
  required LibraryMetadataItem edited,
}) {
  return ingested.copyWith(
    title: edited.title,
    displayTitle: edited.displayTitle ?? ingested.displayTitle,
    localizedTitle: edited.localizedTitle ?? ingested.localizedTitle,
    originalTitle: edited.originalTitle ?? ingested.originalTitle,
    searchAliases: edited.searchAliases ?? ingested.searchAliases,
    sortKey: edited.sortKey ?? ingested.sortKey,
    synopsis: edited.synopsis ?? ingested.synopsis,
    coverImageUrl: edited.coverImageUrl ?? ingested.coverImageUrl,
    thumbnailImageUrl: edited.thumbnailImageUrl ?? ingested.thumbnailImageUrl,
    coverImageData: edited.coverImageData ?? ingested.coverImageData,
    kindMetadata: edited.kindMetadata,
  );
}

LibraryMetadataItem mergeResolvedProviderAddItem({
  required LibraryMetadataItem fallback,
  required LibraryMetadataItem fullItem,
}) {
  return fullItem.displayCoverUrl != null
      ? fullItem
      : fullItem.copyWith(
          coverImageUrl: fallback.coverImageUrl,
          thumbnailImageUrl:
              fallback.thumbnailImageUrl ?? fallback.coverImageUrl,
        );
}

Map<String, dynamic> mergeHydratedProviderAddResultRaw({
  required Map<String, dynamic> raw,
  required LibraryMetadataItem sourceSelection,
}) {
  final payload = sourceSelection.kindMetadata.toSyncPayload();
  final merged = <String, dynamic>{
    ...raw,
    if (!raw.containsKey('editions') && payload['editions'] != null)
      'editions': payload['editions'],
    if (!raw.containsKey('track_count') && payload['track_count'] != null)
      'track_count': payload['track_count'],
    if (!raw.containsKey('tracks') && payload['tracks'] != null)
      'tracks': payload['tracks'],
  };
  return merged;
}

Future<void> applyProviderIngestCorrections({
  required ApiClient api,
  required String kind,
  required String itemId,
  required Map<String, Object?> corrections,
  required LibraryMetadataItem edited,
}) {
  final payload = edited.kindMetadata.toSyncPayload();
  return api.adminUpdateCatalogItem(
    kind: kind,
    id: itemId,
    title: corrections['title'] as String?,
    titleExtension: corrections['title_extension'] as String?,
    sortKey: corrections['sort_key'] as String?,
    originalTitle: corrections['original_title'] as String?,
    localizedTitle: corrections['localized_title'] as String?,
    searchAliases:
        corrections.containsKey('search_aliases') ? edited.searchAliases : null,
    itemNumber: corrections['item_number'] as String?,
    synopsis: corrections['synopsis'] as String?,
    editionTitle: corrections['edition_title'] as String?,
    pageCount: corrections.containsKey('page_count')
        ? payload['page_count'] as int?
        : null,
    publisher: corrections['publisher'] as String?,
    releaseDate: corrections.containsKey('release_date')
        ? _dateFromPayload(payload['release_date'])
        : null,
    runtimeMinutes: corrections.containsKey('runtime_minutes')
        ? payload['runtime_minutes'] as int?
        : null,
    imprint: corrections['imprint'] as String?,
    subtitle: corrections['subtitle'] as String?,
    seriesGroup: corrections['series_group'] as String?,
    country: corrections['country'] as String?,
    language: corrections['language'] as String?,
    ageRating: corrections['age_rating'] as String?,
    audienceRating: corrections['audience_rating'] as String?,
    genres: corrections.containsKey('genres')
        ? (payload['genres'] as List?)?.map((g) => g.toString()).toList()
        : null,
    platforms: corrections.containsKey('platforms')
        ? (payload['platforms'] as List?)?.map((p) => p.toString()).toList()
        : null,
    tracks: corrections.containsKey('tracks')
        ? (payload['tracks'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((t) => CatalogTrack.fromJson(t))
            .toList()
        : null,
    creators: corrections.containsKey('creators')
        ? normalizeCreators((payload['creators'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList())
        : null,
    characters: corrections.containsKey('characters')
        ? (payload['characters'] as List?)?.map((c) => c.toString()).toList()
        : null,
    storyArcs: corrections.containsKey('story_arcs')
        ? (payload['story_arcs'] as List?)?.map((s) => s.toString()).toList()
        : null,
    color: corrections['color'] as String?,
    nrDiscs: corrections.containsKey('nr_discs')
        ? payload['nr_discs'] as int?
        : null,
    screenRatio: corrections['screen_ratio'] as String?,
    audioTracks: corrections['audio_tracks'] as String?,
    subtitles: corrections['subtitles'] as String?,
    layers: corrections['layers'] as String?,
    externalLinks: corrections.containsKey('external_links')
        ? (payload['external_links'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((l) => TrailerLink.fromJson(l))
            .toList()
        : null,
    crossover: corrections['crossover'] as String?,
    plotSummary: corrections['plot_summary'] as String?,
    plotDescription: corrections['plot_description'] as String?,
    catalogNumber: corrections['catalog_number'] as String?,
    releaseStatus: corrections['release_status'] as String?,
    barcode: corrections['barcode'] as String?,
    variantName: corrections['variant_name'] as String?,
    physicalFormat: corrections['physical_format'] as String?,
    coverImageUrl: corrections['cover_image_url'] as String?,
    thumbnailImageUrl: corrections['thumbnail_image_url'] as String?,
    explicitFields: corrections.keys.toSet(),
  );
}

DateTime? _dateFromPayload(Object? value) {
  if (value is DateTime) {
    return value;
  }
  final raw = value?.toString().trim();
  return raw == null || raw.isEmpty ? null : DateTime.tryParse(raw);
}
