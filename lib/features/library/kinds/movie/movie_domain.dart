import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class MovieReleaseMedia {
  const MovieReleaseMedia({
    required this.id,
    required this.releaseId,
    this.title,
    this.formatLabel,
    this.discNumber,
    this.sequenceNumber,
    this.barcode,
    this.frontCoverUrl,
    this.backCoverUrl,
    this.features = const <String>[],
    this.extras = const <String>[],
    this.hdr = const <String>[],
    this.audioTracks = const <String>[],
    this.subtitles = const <String>[],
    this.screenRatios = const <String>[],
    this.regions = const <String>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String releaseId;
  final String? title;
  final String? formatLabel;
  final int? discNumber;
  final int? sequenceNumber;
  final String? barcode;
  final String? frontCoverUrl;
  final String? backCoverUrl;
  final List<String> features;
  final List<String> extras;
  final List<String> hdr;
  final List<String> audioTracks;
  final List<String> subtitles;
  final List<String> screenRatios;
  final List<String> regions;
  final Map<String, dynamic> metadata;

  factory MovieReleaseMedia.fromJson(Map<String, dynamic> json) {
    return MovieReleaseMedia(
      id: _stringOrEmpty(json['id']),
      releaseId: _stringOrEmpty(json['release_id'] ?? json['releaseId']),
      title: _stringOrNull(json['title']),
      formatLabel: _stringOrNull(json['format_label'] ?? json['formatLabel']),
      discNumber: _intOrNull(json['disc_number'] ?? json['discNumber']),
      sequenceNumber:
          _intOrNull(json['sequence_number'] ?? json['sequenceNumber']),
      barcode: _stringOrNull(json['barcode']),
      frontCoverUrl:
          _stringOrNull(json['front_cover_url'] ?? json['frontCoverUrl']),
      backCoverUrl: _stringOrNull(json['back_cover_url'] ?? json['backCoverUrl']),
      features: _stringList(json['features']),
      extras: _stringList(json['extras']),
      hdr: _stringList(json['hdr']),
      audioTracks: _stringList(json['audio_tracks'] ?? json['audioTracks']),
      subtitles: _stringList(json['subtitles']),
      screenRatios: _stringList(json['screen_ratios'] ?? json['screenRatios']),
      regions: _stringList(json['regions']),
      metadata: _metadataMap(json),
    );
  }

  factory MovieReleaseMedia.fromCatalogDisc(
    CatalogDisc disc, {
    required String releaseId,
  }) {
    return MovieReleaseMedia(
      id: '$releaseId:disc:${disc.discNumber}',
      releaseId: releaseId,
      title: disc.discName,
      formatLabel: disc.discFormat,
      discNumber: disc.discNumber,
      metadata: {
        if (disc.storageDevice != null) 'storage_device': disc.storageDevice,
        if (disc.slot != null) 'slot': disc.slot,
        if (disc.matrixSideA != null) 'matrix_side_a': disc.matrixSideA,
        if (disc.matrixSideB != null) 'matrix_side_b': disc.matrixSideB,
      },
    );
  }
}

final class MovieRelease {
  const MovieRelease({
    required this.id,
    required this.workId,
    this.title,
    this.releaseDate,
    this.country,
    this.language,
    this.barcode,
    this.formatLabel,
    this.frontCoverUrl,
    this.backCoverUrl,
    this.boxSetName,
    this.purchaseStore,
    this.purchaseDate,
    this.purchasePriceCents,
    this.currency,
    this.publisher,
    this.distributor,
    this.media = const <MovieReleaseMedia>[],
    this.trailerUrls = const <TrailerLink>[],
    this.externalLinks = const <Map<String, dynamic>>[],
    this.identifiers = const <Map<String, dynamic>>[],
    this.features = const <String>[],
    this.extras = const <String>[],
    this.hdr = const <String>[],
    this.audioTracks = const <String>[],
    this.subtitles = const <String>[],
    this.screenRatios = const <String>[],
    this.regions = const <String>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String workId;
  final String? title;
  final DateTime? releaseDate;
  final String? country;
  final String? language;
  final String? barcode;
  final String? formatLabel;
  final String? frontCoverUrl;
  final String? backCoverUrl;
  final String? boxSetName;
  final String? purchaseStore;
  final DateTime? purchaseDate;
  final int? purchasePriceCents;
  final String? currency;
  final String? publisher;
  final String? distributor;
  final List<MovieReleaseMedia> media;
  final List<TrailerLink> trailerUrls;
  final List<Map<String, dynamic>> externalLinks;
  final List<Map<String, dynamic>> identifiers;
  final List<String> features;
  final List<String> extras;
  final List<String> hdr;
  final List<String> audioTracks;
  final List<String> subtitles;
  final List<String> screenRatios;
  final List<String> regions;
  final Map<String, dynamic> metadata;

  factory MovieRelease.fromJson(Map<String, dynamic> json) {
    return MovieRelease(
      id: _stringOrEmpty(json['id']),
      workId: _stringOrEmpty(json['work_id'] ?? json['workId']),
      title: _stringOrNull(json['title']),
      releaseDate: _dateOrNull(json['release_date'] ?? json['releaseDate']),
      country: _stringOrNull(json['country']),
      language: _stringOrNull(json['language']),
      barcode: _stringOrNull(json['barcode'] ?? json['upc']),
      formatLabel: _stringOrNull(json['format_label'] ?? json['formatLabel']),
      frontCoverUrl:
          _stringOrNull(json['front_cover_url'] ?? json['frontCoverUrl']),
      backCoverUrl: _stringOrNull(json['back_cover_url'] ?? json['backCoverUrl']),
      boxSetName: _stringOrNull(json['box_set_name'] ?? json['boxSetName']),
      purchaseStore:
          _stringOrNull(json['purchase_store'] ?? json['purchaseStore']),
      purchaseDate: _dateOrNull(json['purchase_date'] ?? json['purchaseDate']),
      purchasePriceCents:
          _intOrNull(json['purchase_price_cents'] ?? json['purchasePriceCents']),
      currency: _stringOrNull(json['currency']),
      publisher: _stringOrNull(json['publisher']),
      distributor: _stringOrNull(json['distributor']),
      media: [
        for (final entry in _mapList(json['media'] ?? json['discs']))
          MovieReleaseMedia.fromJson(entry),
      ],
      trailerUrls: [
        for (final entry in _mapList(json['trailer_urls'] ?? json['trailers']))
          TrailerLink.fromJson(entry),
      ],
      externalLinks: _mapList(json['external_links'] ?? json['externalLinks']),
      identifiers: _mapList(json['identifiers']),
      features: _stringList(json['features']),
      extras: _stringList(json['extras']),
      hdr: _stringList(json['hdr']),
      audioTracks: _stringList(json['audio_tracks'] ?? json['audioTracks']),
      subtitles: _stringList(json['subtitles']),
      screenRatios: _stringList(json['screen_ratios'] ?? json['screenRatios']),
      regions: _stringList(json['regions']),
      metadata: _metadataMap(json),
    );
  }

  factory MovieRelease.fromCatalogEdition(
    CatalogEdition edition, {
    required String workId,
  }) {
    return MovieRelease(
      id: edition.id,
      workId: workId,
      title: edition.title,
      releaseDate: edition.releaseDate,
      country: edition.region,
      language: edition.language,
      barcode: edition.upc ?? edition.isbn,
      formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
      publisher: edition.publisher,
      distributor: edition.distributor,
      media: [
        for (final disc in edition.discs)
          MovieReleaseMedia.fromCatalogDisc(disc, releaseId: edition.id),
      ],
      metadata: edition.metadata ?? const <String, dynamic>{},
    );
  }

  CatalogEdition toCatalogEdition() {
    return CatalogEdition(
      id: id,
      title: title ?? 'Release',
      format: formatLabel,
      publisher: publisher,
      distributor: distributor,
      upc: barcode,
      language: language,
      region: country,
      releaseDate: releaseDate,
      physicalFormat: formatLabel,
      physicalFormatLabel: formatLabel,
      metadata: metadata,
      discs: [
        for (final mediaItem in media)
          CatalogDisc(
            discNumber: mediaItem.discNumber ?? 1,
            discName: mediaItem.title,
            discFormat: mediaItem.formatLabel,
            storageDevice: mediaItem.metadata['storage_device']?.toString(),
            slot: mediaItem.metadata['slot']?.toString(),
            matrixSideA: mediaItem.metadata['matrix_side_a']?.toString(),
            matrixSideB: mediaItem.metadata['matrix_side_b']?.toString(),
          ),
      ],
    );
  }

  CatalogPublishingDetails? get publishingDetails {
    if (country == null &&
        language == null &&
        releaseDate == null &&
        formatLabel == null &&
        boxSetName == null &&
        purchaseStore == null &&
        purchaseDate == null &&
        purchasePriceCents == null) {
      return null;
    }
    return CatalogPublishingDetails(
      subtitle: formatLabel,
      originalCountry: country,
      originalLanguage: language,
      originalPublicationDate: releaseDate,
      originalPublisher: distributor ?? publisher,
      publicationPlace: boxSetName,
      coverPriceCents: purchasePriceCents,
      currency: currency,
      subjects: features,
    );
  }

  VideoCatalogDetails? get videoDetails {
    final audio = _joinUnique(audioTracks);
    final subtitlesValue = _joinUnique(subtitles);
    final screenRatio = _joinUnique(screenRatios);
    final layers = _joinUnique(extras);
    if (audio == null &&
        subtitlesValue == null &&
        screenRatio == null &&
        layers == null &&
        media.isEmpty &&
        features.isEmpty &&
        hdr.isEmpty) {
      return null;
    }
    return VideoCatalogDetails(
      nrDiscs: media.isEmpty ? null : media.length,
      screenRatio: screenRatio,
      audioTracks: audio,
      subtitles: subtitlesValue,
      layers: layers,
    );
  }
}

final class MovieWork {
  const MovieWork({
    required this.id,
    required this.title,
    this.originalTitle,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.releaseDate,
    this.runtimeMinutes,
    this.ageRating,
    this.audienceRating,
    this.originalLanguage,
    this.subtitle,
    this.description,
    this.series,
    this.releases = const <MovieRelease>[],
    this.media = const <MovieReleaseMedia>[],
    this.contributions = const <Map<String, dynamic>>[],
    this.characterAppearances = const <Map<String, dynamic>>[],
    this.identifiers = const <Map<String, dynamic>>[],
    this.externalLinks = const <Map<String, dynamic>>[],
    this.trailerUrls = const <TrailerLink>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String? originalTitle;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final DateTime? releaseDate;
  final int? runtimeMinutes;
  final String? ageRating;
  final String? audienceRating;
  final String? originalLanguage;
  final String? subtitle;
  final String? description;
  final CatalogSeriesDetails? series;
  final List<MovieRelease> releases;
  final List<MovieReleaseMedia> media;
  final List<Map<String, dynamic>> contributions;
  final List<Map<String, dynamic>> characterAppearances;
  final List<Map<String, dynamic>> identifiers;
  final List<Map<String, dynamic>> externalLinks;
  final List<TrailerLink> trailerUrls;
  final Map<String, dynamic> metadata;

  factory MovieWork.fromDto(MovieWorkDto dto) {
    return MovieWork.fromJson(dto.raw);
  }

  factory MovieWork.fromCatalogItem(CatalogItem item) {
    return MovieWork.fromJson(item.toSyncPayload());
  }

  factory MovieWork.fromMetadataItem(LibraryMetadataItem item) {
    return MovieWork.fromJson(item.toSyncPayload());
  }

  factory MovieWork.fromWorkspaceEntry(LibraryWorkspaceEntry entry) {
    return MovieWork(
      id: entry.titleItemId ?? entry.id,
      title: entry.title,
      originalTitle: entry.originalTitle,
      synopsis: entry.synopsis,
      coverImageUrl: entry.coverImageUrl,
      thumbnailImageUrl: entry.thumbnailImageUrl,
      releaseDate: entry.releaseDate,
      runtimeMinutes: entry.video?.runtimeMinutes,
      ageRating: entry.ageRating,
      audienceRating: entry.audienceRating,
      series: entry.series,
      releases: [
        for (final edition in entry.editions)
          MovieRelease.fromCatalogEdition(
            edition,
            workId: entry.titleItemId ?? entry.id,
          ),
      ],
      media: [
        for (final edition in entry.editions)
          for (final disc in edition.discs)
            MovieReleaseMedia.fromCatalogDisc(
              disc,
              releaseId: edition.id,
            ),
      ],
      contributions: entry.creators ?? const <Map<String, dynamic>>[],
      characterAppearances: entry.characters == null
          ? const <Map<String, dynamic>>[]
          : [
              for (final character in entry.characters!)
                {'name': character},
            ],
      identifiers: const <Map<String, dynamic>>[],
      externalLinks: const <Map<String, dynamic>>[],
      trailerUrls: entry.trailerUrls,
    );
  }

  factory MovieWork.fromJson(Map<String, dynamic> json) {
    final releases = [
      for (final entry in _mapList(json['releases']))
        MovieRelease.fromJson(entry),
    ];
    return MovieWork(
      id: _stringOrEmpty(json['id']),
      title: _stringOrEmpty(json['title']),
      originalTitle:
          _stringOrNull(json['original_title'] ?? json['originalTitle']),
      synopsis: _stringOrNull(json['description'] ?? json['plot_summary']),
      coverImageUrl:
          _stringOrNull(json['cover_image_url'] ?? json['poster_url']),
      thumbnailImageUrl: _stringOrNull(
        json['thumbnail_image_url'] ?? json['cover_image_url'] ?? json['poster_url'],
      ),
      releaseDate: _dateOrNull(json['release_date'] ?? json['releaseDate']),
      runtimeMinutes: _intOrNull(json['runtime_minutes'] ?? json['runtimeMinutes']),
      ageRating: _stringOrNull(json['age_rating'] ?? json['ageRating']),
      audienceRating:
          _stringOrNull(json['audience_rating'] ?? json['audienceRating']),
      originalLanguage:
          _stringOrNull(json['original_language'] ?? json['originalLanguage']),
      subtitle: _stringOrNull(json['subtitle']),
      description: _stringOrNull(json['description']),
      series: _seriesFromJson(json['series'] ?? json),
      releases: releases,
      media: [
        for (final entry in _mapList(json['media']))
          MovieReleaseMedia.fromJson(entry),
        for (final release in releases) ...release.media,
      ],
      contributions: _mapList(json['contributions']),
      characterAppearances: _mapList(json['character_appearances']),
      identifiers: _mapList(json['identifiers']),
      externalLinks: _mapList(json['external_links']),
      trailerUrls: [
        for (final entry in _mapList(json['trailer_urls']))
          TrailerLink.fromJson(entry),
      ],
      metadata: _metadataMap(json),
    );
  }

  bool get hasMissingCoreMetadata =>
      releaseDate == null &&
      runtimeMinutes == null &&
      coverImageUrl == null &&
      thumbnailImageUrl == null &&
      subtitle == null;

  CatalogPublishingDetails? get publishingDetails {
    final firstRelease = releases.isEmpty ? null : releases.first;
    if (firstRelease == null) {
      return null;
    }
    return firstRelease.publishingDetails;
  }

  VideoCatalogDetails? get videoDetails {
    final release = releases.isEmpty ? null : releases.first;
    if (release == null) {
      return runtimeMinutes == null && audienceRating == null && ageRating == null
          ? null
          : VideoCatalogDetails(
              runtimeMinutes: runtimeMinutes,
              ageRating: ageRating,
              audienceRating: audienceRating,
            );
    }
    return VideoCatalogDetails(
      runtimeMinutes: runtimeMinutes,
      nrDiscs: release.media.isEmpty ? null : release.media.length,
      screenRatio: release.videoDetails?.screenRatio,
      audioTracks: release.videoDetails?.audioTracks,
      subtitles: release.videoDetails?.subtitles,
      layers: release.videoDetails?.layers,
      ageRating: ageRating,
      audienceRating: audienceRating,
    );
  }
}

final class MoviePersonalOverlay {
  const MoviePersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.updatedAt,
    this.isOwnedOverride = false,
    this.isTrackedOverride = false,
    this.isWishlistedOverride = false,
  });

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? updatedAt;
  final bool isOwnedOverride;
  final bool isTrackedOverride;
  final bool isWishlistedOverride;

  bool get isOwned => ownedItem != null || isOwnedOverride;
  bool get isTracked => trackingEntry != null || isTrackedOverride;
  bool get isWishlisted => wishlistItem != null || isWishlistedOverride;

  factory MoviePersonalOverlay.fromShelfEntry(ShelfEntry source) {
    return MoviePersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      updatedAt: source.updatedAt,
    );
  }
}

CatalogSeriesDetails? _seriesFromJson(Object? value) {
  if (value is Map<String, dynamic>) {
    final id = _stringOrNull(value['id'] ?? value['series_id'] ?? value['seriesId']);
    final title = _stringOrNull(
      value['series_title'] ?? value['seriesTitle'] ?? value['title'],
    );
    final volumeName = _stringOrNull(value['volume_name'] ?? value['volumeName']);
    final volumeNumber = (value['volume_number'] ?? value['volumeNumber']) as num?;
    final resolvedVolumeNumber = volumeNumber?.toDouble();
    final volumeStartYear =
        _intOrNull(value['volume_start_year'] ?? value['volumeStartYear']);
    final seasonNumber = _intOrNull(value['season_number'] ?? value['seasonNumber']);
    final episodeNumber = _intOrNull(value['episode_number'] ?? value['episodeNumber']);
    final tags = _stringList(value['tags']);
    if (id == null &&
        title == null &&
        volumeName == null &&
        resolvedVolumeNumber == null &&
        volumeStartYear == null &&
        seasonNumber == null &&
        episodeNumber == null &&
        tags.isEmpty) {
      return null;
    }
    return CatalogSeriesDetails(
      seriesId: id,
      seriesTitle: title,
      volumeName: volumeName,
      volumeNumber: resolvedVolumeNumber,
      volumeStartYear: volumeStartYear,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      tags: tags,
    );
  }
  if (value is! List || value.isEmpty) {
    return null;
  }
  final first = value.first;
  if (first is String) {
    final title = first.trim();
    if (title.isEmpty) {
      return null;
    }
    return CatalogSeriesDetails(seriesTitle: title);
  }
  if (first is Map<String, dynamic>) {
    final id = _stringOrNull(first['id'] ?? first['series_id'] ?? first['seriesId']);
    final title = _stringOrNull(
      first['series_title'] ?? first['seriesTitle'] ?? first['title'],
    );
    if (id == null && title == null) {
      return null;
    }
    return CatalogSeriesDetails(
      seriesId: id,
      seriesTitle: title,
      tags: _stringList(first['tags']),
    );
  }
  return null;
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) Map<String, dynamic>.from(entry),
  ];
}

Map<String, dynamic> _metadataMap(Map<String, dynamic> json) {
  final metadata = json['metadata_json'];
  if (metadata is Map<String, dynamic>) {
    return Map<String, dynamic>.from(metadata);
  }
  return const <String, dynamic>{};
}

String _stringOrEmpty(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? '' : text;
}

String? _stringOrNull(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _intOrNull(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _dateOrNull(Object? value) {
  final text = _stringOrNull(value);
  return text == null ? null : DateTime.tryParse(text);
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  final result = <String>[];
  final seen = <String>{};
  for (final entry in value) {
    final text = entry?.toString().trim();
    if (text == null || text.isEmpty) {
      continue;
    }
    final marker = text.toLowerCase();
    if (seen.add(marker)) {
      result.add(text);
    }
  }
  return result;
}

String? _joinUnique(List<String> values) {
  if (values.isEmpty) {
    return null;
  }
  return values.toSet().join(', ');
}
