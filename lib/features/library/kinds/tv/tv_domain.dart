import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_mapper.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

export 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
export 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
export 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';
export 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
export 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
export 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_card_presentation.dart';
export 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
export 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_mapper.dart';
export 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_release.dart';

// ---------------------------------------------------------------------------
// Transitional typedefs
// ---------------------------------------------------------------------------
typedef TvWork = VideoCatalogItem;

// ---------------------------------------------------------------------------
// TvEpisode
// ---------------------------------------------------------------------------
class TvEpisode {
  const TvEpisode({
    this.id = '',
    this.seasonId,
    this.seriesId,
    this.title = '',
    this.seasonNumber = 1,
    this.episodeNumber = 1,
    this.overview,
    this.airDate,
    this.runtimeMinutes,
    this.stillUrl,
    this.originalTitle,
  });

  factory TvEpisode.fromJson(Map<String, dynamic> json) {
    final rawAirDate = json['air_date'] ?? json['release_date'];
    return TvEpisode(
      id: json['id'] as String? ?? '',
      seasonId: json['season_id'] as String?,
      seriesId: json['series_id'] as String?,
      title: json['title'] as String? ?? '',
      seasonNumber: json['season_number'] as int? ?? 1,
      episodeNumber: json['episode_number'] as int? ?? 1,
      overview: (json['overview'] ?? json['synopsis']) as String?,
      airDate: rawAirDate is String ? DateTime.tryParse(rawAirDate) : null,
      runtimeMinutes: json['runtime_minutes'] as int?,
      stillUrl: json['still_url'] as String?,
      originalTitle: json['original_title'] as String?,
    );
  }

  final String id;
  final String? seasonId;
  final String? seriesId;
  final String title;
  final int seasonNumber;
  final int episodeNumber;
  final String? overview;
  final DateTime? airDate;
  final int? runtimeMinutes;
  final String? stillUrl;
  final String? originalTitle;
}

// ---------------------------------------------------------------------------
// TvSeason
// ---------------------------------------------------------------------------
class TvSeason {
  const TvSeason({
    this.id = '',
    this.seriesId = '',
    this.seasonNumber = 1,
    this.title,
    this.overview,
    this.airDate,
    this.episodeCount,
    this.posterUrl,
    this.originalTitle,
    this.episodes = const [],
  });

  factory TvSeason.fromJson(Map<String, dynamic> json) {
    final rawAirDate = json['air_date'] ?? json['release_date'];
    final rawEpisodes = (json['episodes'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(TvEpisode.fromJson)
            .toList() ??
        const <TvEpisode>[];
    return TvSeason(
      id: json['id'] as String? ?? '',
      seriesId: json['series_id'] as String? ?? '',
      seasonNumber: json['season_number'] as int? ?? 1,
      title: json['title'] as String?,
      overview: (json['overview'] ?? json['synopsis']) as String?,
      airDate: rawAirDate is String ? DateTime.tryParse(rawAirDate) : null,
      episodeCount: json['episode_count'] as int?,
      posterUrl: (json['poster_url'] ?? json['cover_image_url']) as String?,
      originalTitle: json['original_title'] as String?,
      episodes: rawEpisodes,
    );
  }

  final String id;
  final String seriesId;
  final int seasonNumber;
  final String? title;
  final String? overview;
  final DateTime? airDate;
  final int? episodeCount;
  final String? posterUrl;
  final String? originalTitle;
  final List<TvEpisode> episodes;
}

// ---------------------------------------------------------------------------
// TvSeries
// ---------------------------------------------------------------------------
class TvSeries {
  const TvSeries({
    this.id = '',
    this.title = '',
    this.originalTitle,
    this.overview,
    this.firstAirDate,
    this.lastAirDate,
    this.status,
    this.type,
    this.network,
    this.originalLanguage,
    this.country,
    this.runtimeMinutes,
    this.seriesDetails,
    this.publishingDetails,
    this.seasonCount,
    this.episodeCount,
    this.posterUrl,
    this.backdropUrl,
    this.seasons = const [],
    this.releases = const [],
    this.media = const [],
    this.releaseEpisodeMaps = const [],
    this.contributions = const [],
    this.identifiers = const [],
    this.characterAppearances = const [],
    this.metadata = const {},
  });

  factory TvSeries.fromMetadataItem(LibraryMetadataItem item) {
    return TvSeries(
      id: item.id,
      title: item.title,
      originalTitle: item.originalTitle,
      overview: item.synopsis,
      firstAirDate: item.releaseDate,
      network: item.publisher,
      originalLanguage: item.language,
      country: item.country,
      runtimeMinutes: item.video?.runtimeMinutes,
      seriesDetails: item.series,
      publishingDetails: item.publishing,
      contributions: item.creators ?? const [],
      characterAppearances: item.characterDetails ?? const [],
    );
  }

  final String id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final String? status;
  final String? type;
  final String? network;
  final String? originalLanguage;
  final String? country;
  final int? runtimeMinutes;
  final CatalogSeriesDetails? seriesDetails;
  final CatalogPublishingDetails? publishingDetails;
  final int? seasonCount;
  final int? episodeCount;
  final String? posterUrl;
  final String? backdropUrl;
  final List<TvSeason> seasons;
  final List<TvRelease> releases;
  final List<TvReleaseMedia> media;
  final List<TvReleaseEpisodeMap> releaseEpisodeMaps;
  final List<Map<String, dynamic>> contributions;
  final List<Map<String, dynamic>> identifiers;
  final List<Map<String, dynamic>> characterAppearances;
  final Map<String, dynamic> metadata;
}

// ---------------------------------------------------------------------------
// TvRelease
// ---------------------------------------------------------------------------
class TvRelease {
  const TvRelease({
    required this.id,
    required this.seriesId,
    this.title,
    this.publisher,
    this.distributor,
    this.barcode,
    this.releaseDate,
    this.formatLabel,
    this.frontCoverUrl,
    this.country,
    this.language,
    this.media = const [],
    this.publishingDetails,
    this.videoDetails,
    this.episodeMappings = const [],
  });

  factory TvRelease.fromCatalogEdition(
    CatalogEdition edition, {
    required String seriesId,
  }) {
    final discs = edition.discs
        .map((disc) => TvReleaseMedia(
              id: '${edition.id}:disc:${disc.discNumber}',
              releaseId: edition.id,
              sequenceNumber: disc.discNumber ?? 1,
              name: disc.discName,
              discNumber: disc.discNumber,
              formatLabel: disc.discFormat,
            ))
        .toList();
    return TvRelease(
      id: edition.id,
      seriesId: seriesId,
      title: edition.title,
      publisher: edition.publisher,
      distributor: edition.distributor,
      barcode: edition.upc ?? edition.isbn,
      releaseDate: edition.releaseDate,
      formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
      media: discs,
    );
  }

  CatalogEdition toCatalogEdition() {
    return CatalogEdition(
      id: id,
      title: title ?? '',
      publisher: publisher,
      distributor: distributor,
      upc: barcode,
      releaseDate: releaseDate,
      physicalFormat: formatLabel,
      physicalFormatLabel: formatLabel,
    );
  }

  final String id;
  final String seriesId;
  final String? title;
  final String? publisher;
  final String? distributor;
  final String? barcode;
  final DateTime? releaseDate;
  final String? formatLabel;
  final String? frontCoverUrl;
  final String? country;
  final String? language;
  final List<TvReleaseMedia> media;
  final CatalogPublishingDetails? publishingDetails;
  final VideoCatalogDetails? videoDetails;
  final List<TvReleaseEpisodeMap> episodeMappings;
}

// ---------------------------------------------------------------------------
// TvReleaseMedia
// ---------------------------------------------------------------------------
class TvReleaseMedia {
  const TvReleaseMedia({
    this.id = '',
    this.releaseId = '',
    this.sequenceNumber = 1,
    this.name,
    this.title,
    this.discNumber,
    this.formatLabel,
    this.features = const <String>[],
    this.episodes = const [],
  });

  final String id;
  final String releaseId;
  final int sequenceNumber;
  final String? name;
  final String? title;
  final int? discNumber;
  final String? formatLabel;
  final List<String> features;
  final List<TvEpisode> episodes;
}

// ---------------------------------------------------------------------------
// TvReleaseEpisodeMap
// ---------------------------------------------------------------------------
class TvReleaseEpisodeMap {
  const TvReleaseEpisodeMap({
    this.id = '',
    this.releaseId,
    this.mediaId,
    this.episodeId,
    this.sequenceNumber,
    this.discNumber,
  });

  final String id;
  final String? releaseId;
  final String? mediaId;
  final String? episodeId;
  final int? sequenceNumber;
  final int? discNumber;
}

// ---------------------------------------------------------------------------
// TvPersonalOverlay
// ---------------------------------------------------------------------------
final class TvPersonalOverlay {
  const TvPersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.updatedAt,
    this.isOwnedOverride,
    this.isTrackedOverride,
    this.isWishlistedOverride,
  });

  factory TvPersonalOverlay.fromShelf(ShelfEntry source) {
    return TvPersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      watchSessions: source.watchSessions,
      itemImages: source.itemImages,
      updatedAt: source.updatedAt,
    );
  }

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final DateTime? updatedAt;
  final bool? isOwnedOverride;
  final bool? isTrackedOverride;
  final bool? isWishlistedOverride;

  bool get isOwned => isOwnedOverride ?? ownedItem != null;
  bool get isTracked => isTrackedOverride ?? trackingEntry != null;
  bool get isWishlisted => isWishlistedOverride ?? wishlistItem != null;
}

// ---------------------------------------------------------------------------
// TvWorkspaceNode
// ---------------------------------------------------------------------------
enum TvWorkspaceNodeType { series, season, episode }

class TvWorkspaceNode {
  const TvWorkspaceNode({
    required this.id,
    required this.title,
    required this.nodeType,
  });

  final String id;
  final String title;
  final TvWorkspaceNodeType nodeType;
}

// ---------------------------------------------------------------------------
// Extension for VideoCatalogMapper used in tv workspace builder
// ---------------------------------------------------------------------------
extension TvVideoCatalogMapperExt on VideoCatalogMapper {
  static VideoCatalogItem fromTvMetadataItem(LibraryMetadataItem item) {
    return VideoCatalogMapper.mapDtoToVideo(CatalogItemDto(
      id: item.id,
      mediaKind: item.mediaKind,
      title: item.title,
      originalTitle: item.originalTitle,
      synopsis: item.synopsis,
      releaseDate: item.releaseDate,
      publisher: item.publisher,
      language: item.language,
      video: item.video,
      editions: item.editions,
    ));
  }
}
