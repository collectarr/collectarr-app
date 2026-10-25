import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_module.dart'
    show boardGameKindMetadata;
import 'package:collectarr_app/features/library/kinds/book/book_module.dart'
    show bookKindMetadata;
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart'
    show comicKindMetadata;
import 'package:collectarr_app/features/library/kinds/game/game_module.dart'
    show gameKindMetadata;
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart'
    show movieKindMetadata;
import 'package:collectarr_app/features/library/kinds/music/music_module.dart'
    show musicKindMetadata;
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

CatalogItemDto testCatalogItem({
  String id = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  String? displayTitle,
  String? localizedTitle,
  String? originalTitle,
  String? titleExtension,
  List<String>? searchAliases,
  String? synopsis,
  String? coverImageUrl,
  String? thumbnailImageUrl,
  String? coverImageData,
  String? publisher,
  String? barcode,
  String? variant,
  String? country,
  String? language,
  String? ageRating,
  String? itemNumber,
  String? editionTitle,
  String? physicalFormat,
  String? physicalFormatLabel,
  String? sortKey,
  int? releaseYear,
  DateTime? releaseDate,
  List<String>? genres,
  List<String>? platforms,
  List<String>? rawPlatforms,
  List<String>? characters,
  List<String>? storyArcs,
  List<Map<String, dynamic>>? creators,
  List<Map<String, dynamic>>? editions,
  List<Map<String, dynamic>>? trailerUrls,
  dynamic series,
  dynamic video,
  dynamic music,
  dynamic game,
  dynamic publishing,
  Map<String, dynamic>? payload,
}) {
  final mergedPayload = <String, dynamic>{
    if (itemNumber != null) 'item_number': itemNumber,
    if (editionTitle != null) 'edition_title': editionTitle,
    if (physicalFormat != null) 'physical_format': physicalFormat,
    if (physicalFormatLabel != null && kind != 'movie')
      'physical_format_label': physicalFormatLabel,
    if (publisher != null) 'publisher': publisher,
    if (barcode != null) 'barcode': barcode,
    if (variant != null)
      (kind == 'movie' ? 'variant_name' : 'variant'): variant,
    if (country != null) 'country': country,
    if (language != null) 'language': language,
    if (ageRating != null) 'age_rating': ageRating,
    if (genres != null) 'genres': genres,
    if (platforms != null || rawPlatforms != null)
      'platforms': platforms ?? rawPlatforms,
    if (rawPlatforms != null) 'raw_platforms': rawPlatforms,
    if (characters != null) 'characters': characters,
    if (storyArcs != null) 'story_arcs': storyArcs,
    if (creators != null) 'creators': creators,
    if (series != null)
      'series': series is Map ? series : (series as dynamic).toJson(),
    if (video != null) 'video': video,
    if (music != null) 'music': music,
    if (game != null) 'game': game,
    if (publishing != null)
      'publishing':
          publishing is Map ? publishing : (publishing as dynamic).toJson(),
    if (payload != null) ...payload,
  };
  final kindData = kind == 'music'
      ? <String, dynamic>{
          'title': title,
          'revision': 1,
          if (publisher != null) 'label': publisher,
          if (barcode != null) 'barcode': barcode,
          if (releaseDate != null)
            'release_date': {
              'year': releaseDate.year,
              'month': releaseDate.month,
              'day': releaseDate.day,
            },
          if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
          if (thumbnailImageUrl != null)
            'thumbnail_image_url': thumbnailImageUrl,
          'artist_credits': const <Map<String, dynamic>>[],
          'genres': genres ?? const <String>[],
          'extra': const <String>[],
          'credits': const <Map<String, dynamic>>[],
          'external_links': const <Map<String, dynamic>>[],
          'discs': [
            if (physicalFormat != null || physicalFormatLabel != null)
              {
                'id': 'test-disc-$id',
                'disc_number': 1,
                if ((physicalFormatLabel ?? physicalFormat)?.isNotEmpty == true)
                  'format': physicalFormatLabel ?? physicalFormat,
                'sound_types': const <String>[],
                'recording_locations': const <String>[],
                'credits': const <Map<String, dynamic>>[],
                'tracks': const <Map<String, dynamic>>[],
              },
          ],
          if (music is Map<String, dynamic>) ...music,
          ...?payload,
        }
      : <String, dynamic>{
          'title': title,
          if (displayTitle != null) 'display_title': displayTitle,
          if (localizedTitle != null) 'localized_title': localizedTitle,
          if (originalTitle != null) 'original_title': originalTitle,
          if (titleExtension != null) 'title_extension': titleExtension,
          if (searchAliases != null) 'search_aliases': searchAliases,
          if (synopsis != null) 'synopsis': synopsis,
          if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
          if (thumbnailImageUrl != null)
            'thumbnail_image_url': thumbnailImageUrl,
          if (coverImageData != null) 'cover_image_data': coverImageData,
          if (sortKey != null) 'sort_key': sortKey,
          if (releaseDate != null)
            'release_date': releaseDate.toIso8601String(),
          if (releaseYear != null) 'release_year': releaseYear,
          if (editions != null) 'editions': editions,
          if (trailerUrls != null) 'trailer_urls': trailerUrls,
          ...mergedPayload,
        };
  return CatalogItemDto.raw(
    id: id,
    mediaKind: catalogMediaKindFromValue(kind),
    kindData: kindData,
  );
}

extension ShelfCatalogFixture on CatalogItemDto {
  CatalogItemDto get asShelfCatalogItem => this;

  CatalogSearchCandidate get asSearchCandidate =>
      CatalogSearchCandidate.fromItem(this);

  CatalogDisplaySummary get asShelfCatalogSummary => CatalogDisplaySummary(
        ref: catalogItemRef,
        kind: mediaKind,
        primaryLabel: (kindData['title'] as String?) ?? id,
        imageUrl: (kindData['cover_image_url'] as String?) ??
            (kindData['thumbnail_image_url'] as String?),
      );

  LibraryWorkspaceKindData get asShelfCatalogData =>
      testWorkspaceCatalogData(this);
}

LibraryWorkspaceKindData testWorkspaceCatalogData(CatalogItemDto item) {
  final codecs = {
    CatalogMediaKind.boardgame: boardGameKindMetadata.catalogTransportCodec,
    CatalogMediaKind.book: bookKindMetadata.catalogTransportCodec,
    CatalogMediaKind.comic: comicKindMetadata.catalogTransportCodec,
    CatalogMediaKind.game: gameKindMetadata.catalogTransportCodec,
    CatalogMediaKind.movie: movieKindMetadata.catalogTransportCodec,
    CatalogMediaKind.music: musicKindMetadata.catalogTransportCodec,
  };
  return codecs[item.mediaKind]!.workspaceData(item);
}

CatalogItemDto testCatalogItemFromJson(Map<String, dynamic> json) {
  return CatalogItemDto.fromJson(json);
}

CatalogItemRef testCatalogRef(
  String id, {
  String kind = 'unknown',
}) {
  return CatalogItemRef(
    kind: catalogMediaKindFromApiValue(kind),
    id: id,
  );
}
