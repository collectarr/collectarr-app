import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_comparisons.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

LibraryMetadataItem mergeProviderAddResult({
  required LibraryMetadataItem ingested,
  required LibraryMetadataItem edited,
}) {
  final mergedPublishing = CatalogPublishingDetails(
    pageCount: ingested.publishing?.pageCount,
    coverPriceCents: ingested.publishing?.coverPriceCents,
    currency: ingested.publishing?.currency,
    imprint: edited.publishing?.imprint,
    subtitle: ingested.publishing?.subtitle,
    seriesGroup: edited.publishing?.seriesGroup,
  );

  return ingested.copyWith(
    title: edited.title,
    itemNumber: edited.itemNumber,
    synopsis: edited.synopsis,
    coverImageUrl: edited.coverImageUrl ?? ingested.coverImageUrl,
    thumbnailImageUrl: edited.thumbnailImageUrl ?? ingested.thumbnailImageUrl,
    editionTitle: edited.editionTitle,
    physicalFormat: edited.physicalFormat,
    physicalFormatLabel: edited.physicalFormatLabel,
    publisher: edited.publisher,
    releaseDate: edited.releaseDate,
    releaseYear: edited.releaseYear,
    barcode: edited.barcode,
    variant: edited.variant,
    series: edited.series ?? ingested.series,
    publishing: mergedPublishing.hasData ? mergedPublishing : null,
    creators: edited.creators ?? ingested.creators,
    characters: edited.characters ?? ingested.characters,
    storyArcs: edited.storyArcs ?? ingested.storyArcs,
    genres: edited.genres ?? ingested.genres,
    country: edited.country ?? ingested.country,
    language: edited.language ?? ingested.language,
    ageRating: edited.ageRating ?? ingested.ageRating,
  );
}

LibraryMetadataItem mergeResolvedProviderAddItem({
  required LibraryMetadataItem fallback,
  required LibraryMetadataItem fullItem,
}) {
  var merged = fullItem;
  if (merged.editions.isEmpty && fallback.editions.isNotEmpty) {
    merged = merged.copyWith(editions: fallback.editions);
  }
  final fallbackMusic = fallback.music;
  final currentMusic = merged.music;
  if (fallbackMusic != null && currentMusic != null) {
    final mergedMusic = MusicCatalogDetails(
      trackCount: currentMusic.trackCount ?? fallbackMusic.trackCount,
      tracks: currentMusic.tracks.isNotEmpty
          ? currentMusic.tracks
          : fallbackMusic.tracks,
      discs: currentMusic.discs.isNotEmpty
          ? currentMusic.discs
          : fallbackMusic.discs,
      catalogNumber: currentMusic.catalogNumber ?? fallbackMusic.catalogNumber,
      releaseStatus: currentMusic.releaseStatus ?? fallbackMusic.releaseStatus,
      originalReleaseDate:
          currentMusic.originalReleaseDate ?? fallbackMusic.originalReleaseDate,
      recordingDate: currentMusic.recordingDate ?? fallbackMusic.recordingDate,
      studio: currentMusic.studio ?? fallbackMusic.studio,
      rpm: currentMusic.rpm ?? fallbackMusic.rpm,
      spars: currentMusic.spars ?? fallbackMusic.spars,
      soundType: currentMusic.soundType ?? fallbackMusic.soundType,
      vinylColor: currentMusic.vinylColor ?? fallbackMusic.vinylColor,
      vinylWeight: currentMusic.vinylWeight ?? fallbackMusic.vinylWeight,
      mediaCondition: currentMusic.mediaCondition ?? fallbackMusic.mediaCondition,
      instrument: currentMusic.instrument ?? fallbackMusic.instrument,
      isLive: currentMusic.isLive ?? fallbackMusic.isLive,
      composition: currentMusic.composition ?? fallbackMusic.composition,
    );
    if (mergedMusic.hasData) {
      merged = merged.copyWith(music: mergedMusic);
    }
  } else if (currentMusic == null && fallbackMusic != null) {
    merged = merged.copyWith(music: fallbackMusic);
  }
  return merged.displayCoverUrl != null
      ? merged
      : merged.copyWith(
          coverImageUrl: fallback.coverImageUrl,
          thumbnailImageUrl: fallback.thumbnailImageUrl ?? fallback.coverImageUrl,
        );
}

Map<String, dynamic> mergeHydratedProviderAddResultRaw({
  required Map<String, dynamic> raw,
  required LibraryMetadataItem sourceSelection,
}) {
  final merged = <String, dynamic>{
    ...raw,
    if (!raw.containsKey('editions') && sourceSelection.editions.isNotEmpty)
      'editions': [
        for (final edition in sourceSelection.editions) edition.toJson(),
      ],
    if (!raw.containsKey('track_count') &&
        sourceSelection.music?.trackCount != null)
      'track_count': sourceSelection.music!.trackCount,
    if (!raw.containsKey('tracks') &&
        (sourceSelection.music?.tracks.isNotEmpty ?? false))
      'tracks': [
        for (final track in sourceSelection.music!.tracks) track.toJson(),
      ],
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
        ? edited.publishing?.pageCount
        : null,
    publisher: corrections['publisher'] as String?,
    releaseDate:
        corrections.containsKey('release_date') ? edited.releaseDate : null,
    runtimeMinutes: corrections.containsKey('runtime_minutes')
        ? edited.video?.runtimeMinutes
        : null,
    imprint: corrections['imprint'] as String?,
    subtitle: corrections['subtitle'] as String?,
    seriesGroup: corrections['series_group'] as String?,
    country: corrections['country'] as String?,
    language: corrections['language'] as String?,
    ageRating: corrections['age_rating'] as String?,
    audienceRating: corrections['audience_rating'] as String?,
    genres: corrections.containsKey('genres') ? edited.genres : null,
    platforms: corrections.containsKey('platforms') ? edited.game?.platforms : null,
    tracks: corrections.containsKey('tracks') ? edited.music?.tracks : null,
    creators:
        corrections.containsKey('creators') ? normalizeCreators(edited.creators) : null,
    characters: corrections.containsKey('characters') ? edited.characters : null,
    storyArcs: corrections.containsKey('story_arcs') ? edited.storyArcs : null,
    color: corrections['color'] as String?,
    nrDiscs: corrections.containsKey('nr_discs') ? edited.video?.nrDiscs : null,
    screenRatio: corrections['screen_ratio'] as String?,
    audioTracks: corrections['audio_tracks'] as String?,
    subtitles: corrections['subtitles'] as String?,
    layers: corrections['layers'] as String?,
    externalLinks:
        corrections.containsKey('external_links') ? edited.trailerUrls : null,
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