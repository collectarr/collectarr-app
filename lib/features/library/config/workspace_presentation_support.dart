import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/utils/text_utils.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

String defaultLibraryBucketLabel(
    LibraryBucketingContext context, LibraryMediaGroupLabels labels,
    [LibraryBucketLabelOverrides overrides =
        const LibraryBucketLabelOverrides()]) {
  final item = context.item;
  final dto = item.dto;
  final source = context.source;
  final payload = source.catalogItem?.toSyncPayload() ?? const {};
  final pub = (payload['publishing'] as Map?) ?? payload;
  final video = (payload['video'] as Map?) ?? payload;
  final music = (payload['music'] as Map?) ?? payload;
  final game = (payload['game'] as Map?) ?? payload;
  final publisher = dto.publisher?.trim();
  return switch (context.groupMode) {
    'series' => _seriesBucket(item, labels.unknownSeries),
    'story_arc' => overrides.storyArc,
    'character' => overrides.character,
    'year' => dto.releaseDate?.year.toString() ?? 'Unknown year',
    'audience_rating' => dto.audienceRating?.trim().isNotEmpty == true
        ? dto.audienceRating!
        : 'No audience rating',
    'color' => _stringBucket(video['color']?.toString(), 'No color'),
    'publisher' => publisher == null || publisher.isEmpty
        ? labels.unknownPublisher
        : publisher,
    'genre' => _firstOrDefault(
        (payload['genres'] as List?)?.map((e) => e.toString()).toList(),
        overrides.noGenre,
      ),
    'platform' => _firstOrDefault(
        ((game['platforms'] ?? payload['platforms']) as List?)
            ?.map((e) => e.toString())
            .toList(),
        'No platform',
      ),
    'developer' => _creatorBucketByRole(item, 'developer'),
    'country' => dto.country?.trim().isNotEmpty == true
        ? dto.country!
        : overrides.unknownCountry,
    'language' => dto.language?.trim().isNotEmpty == true
        ? dto.language!
        : overrides.unknownLanguage,
    'age_rating' =>
      dto.ageRating?.trim().isNotEmpty == true ? dto.ageRating! : 'Unrated',
    'crossover' =>
      _stringBucket(payload['crossover']?.toString(), 'No crossover'),
    'imprint' => _stringBucket(pub['imprint']?.toString(), 'No imprint'),
    'series_group' => _stringBucket(
        (pub['series_group'] ?? pub['seriesGroup'])?.toString(),
        'No series group',
      ),
    'movie_or_tv_series' => _movieOrTvSeriesBucket(item),
    'release_date' => _dateBucket(dto.releaseDate, 'Unknown release date'),
    'release_month' =>
      _monthBucket(dto.releaseDate, fallback: 'Unknown release month'),
    'release_year' => _yearBucket(
        dto.releaseDate,
        'Unknown release year',
      ),
    'publication_place' => _stringBucket(
        (pub['publication_place'] ?? pub['original_publication_place'])
            ?.toString(),
        'Unknown publication place',
      ),
    'original_release_date' => _dateBucket(
        DateTime.tryParse(music['original_release_date']?.toString() ?? ''),
        'Unknown original release date',
      ),
    'original_release_month' => _monthBucket(
        DateTime.tryParse(music['original_release_date']?.toString() ?? ''),
        fallback: 'Unknown original release month',
      ),
    'original_release_year' => _yearBucket(
        DateTime.tryParse(music['original_release_date']?.toString() ?? ''),
        'Unknown original release year',
      ),
    'original_country' => _stringBucket(
        (pub['original_country'] ?? payload['country'])?.toString(),
        'Unknown original country',
      ),
    'original_language' => _stringBucket(
        (pub['original_language'] ?? payload['language'])?.toString(),
        'Unknown original language',
      ),
    'original_publication_date' => _dateBucket(
        DateTime.tryParse(pub['original_publication_date']?.toString() ?? ''),
        'Unknown original publication date',
      ),
    'original_publication_month' => _monthBucket(
        DateTime.tryParse(pub['original_publication_date']?.toString() ?? ''),
        fallback: 'Unknown original publication month',
      ),
    'original_publication_year' => _yearBucket(
        DateTime.tryParse(pub['original_publication_date']?.toString() ?? ''),
        'Unknown original publication year',
      ),
    'original_publication_place' => _stringBucket(
        pub['original_publication_place']?.toString(),
        'Unknown original publication place',
      ),
    'original_publisher' => _stringBucket(
        (pub['original_publisher'] ?? payload['publisher'])?.toString(),
        'Unknown original publisher',
      ),
    'recording_date' => _dateBucket(
        DateTime.tryParse(music['recording_date']?.toString() ?? ''),
        'Unknown recording date',
      ),
    'recording_month' => _monthBucket(
        DateTime.tryParse(music['recording_date']?.toString() ?? ''),
        fallback: 'Unknown recording month',
      ),
    'recording_year' => _yearBucket(
        DateTime.tryParse(music['recording_date']?.toString() ?? ''),
        'Unknown recording year',
      ),
    'cover_date' => _dateBucket(
        DateTime.tryParse(payload['cover_date']?.toString() ?? ''),
        'Unknown cover date',
      ),
    'cover_month' => _monthBucket(
        DateTime.tryParse(payload['cover_date']?.toString() ?? ''),
        fallback: 'Unknown cover month',
      ),
    'cover_year' => _yearBucket(
        DateTime.tryParse(payload['cover_date']?.toString() ?? ''),
        'Unknown cover year',
      ),
    'audio_tracks' => _stringBucket(
        (video['audio_tracks'] ?? video['audioTracks'])?.toString(),
        'No audio tracks',
      ),
    'box_set' => _stringBucket(
        source.ownedItem?.videoLikeDetails?.boxSetName,
        'No box set',
      ),
    'completeness' => _stringBucket(
        source.ownedItem?.gameDetails?.completeness,
        'No completeness',
      ),
    'value_locked' => source.ownedItem?.gameDetails?.valueIsLocked == true
        ? 'Locked'
        : 'Unlocked',
    'dust_jacket_condition' => _stringBucket(
        pub['dust_jacket_condition']?.toString(),
        'No dust jacket condition',
      ),
    'distributor' => _stringBucket(
        source.ownedItem?.videoLikeDetails?.distributor,
        'No distributor',
      ),
    'instrument' =>
      _stringBucket(music['instrument']?.toString(), 'No instrument'),
    'is_live' => music['is_live'] == true ? 'Live' : 'Not live',
    'media_condition' => _stringBucket(
        music['media_condition']?.toString(),
        'No media condition',
      ),
    'rpm' => _stringBucket(music['rpm']?.toString(), 'No RPM'),
    'spars' => _stringBucket(music['spars']?.toString(), 'No SPARS'),
    'sound_type' => _stringBucket(music['sound_type']?.toString(), 'No sound'),
    'studio' => _stringBucket(music['studio']?.toString(), 'No studio'),
    'vinyl_color' =>
      _stringBucket(music['vinyl_color']?.toString(), 'No vinyl color'),
    'toy_subtype' =>
      _stringBucket(game['toy_subtype']?.toString(), 'No subtype'),
    'toy_type' => _stringBucket(game['toy_type']?.toString(), 'No type'),
    'edition' => _stringBucket(dto.variant ?? dto.editionLabel, 'No edition'),
    'audiobook_abridged' =>
      pub['audiobook_abridged'] == true ? 'Abridged' : 'Unabridged / Unknown',
    'first_edition' =>
      pub['first_edition'] == true ? 'First edition' : 'Not first edition',
    'narrator' => _creatorBucketByRole(item, 'narrator'),
    'paper_type' =>
      _stringBucket(pub['paper_type']?.toString(), 'No paper type'),
    'printed_by' => _stringBucket(pub['printed_by']?.toString(), 'No printer'),
    'edition_release_date' => _dateBucket(
        _referenceEditionForEntry(item)?.releaseDate,
        'Unknown edition release date',
      ),
    'edition_release_month' => _monthBucket(
        _referenceEditionForEntry(item)?.releaseDate,
        fallback: 'Unknown edition release month',
      ),
    'edition_release_year' => _yearBucket(
        _referenceEditionForEntry(item)?.releaseDate,
        'Unknown edition release year',
      ),
    'extras' => _stringBucket(
        source.ownedItem?.videoLikeDetails?.features,
        'No extras',
      ),
    'format' => _editionFormatBucket(item),
    'hdr' => _firstOrDefault(
        source.ownedItem?.videoLikeDetails?.hdrFormats,
        'No HDR',
      ),
    'layers' => _stringBucket(video['layers']?.toString(), 'No layers'),
    'packaging' => _stringBucket(
        source.ownedItem?.videoLikeDetails?.packaging,
        'No packaging',
      ),
    'regions' => _stringBucket(_referenceRegionFor(source, item), 'No region'),
    'screen_ratios' => _stringBucket(
        (video['screen_ratio'] ?? video['screenRatio'])?.toString(),
        'No screen ratio',
      ),
    'subtitles' =>
      _stringBucket(video['subtitles']?.toString(), 'No subtitles'),
    'actor' => _creatorBucketByRole(item, 'actor'),
    'chorus' => _creatorBucketByRole(item, 'chorus'),
    'composer' => _creatorBucketByRole(item, 'composer'),
    'composition' =>
      _stringBucket(music['composition']?.toString(), 'No composition'),
    'conductor' => _creatorBucketByRole(item, 'conductor'),
    'engineer' => _creatorBucketByRole(item, 'engineer'),
    'director' => _creatorBucketByRole(item, 'director'),
    'musician' => _creatorBucketByRole(item, 'musician'),
    'orchestra' => _creatorBucketByRole(item, 'orchestra'),
    'photography' => _creatorBucketByRole(item, 'photography'),
    'producer' => _creatorBucketByRole(item, 'producer'),
    'creator' => _creatorBucketByRole(item, null),
    'writer' => _creatorBucketByRole(item, 'writer'),
    'artist' => _creatorBucketByRole(item, 'artist'),
    'penciller' => _creatorBucketByRole(item, 'penciller'),
    'inker' => _creatorBucketByRole(item, 'inker'),
    'colorist' => _creatorBucketByRole(item, 'colorist'),
    'painter' => _creatorBucketByRole(item, 'painter'),
    'letterer' => _creatorBucketByRole(item, 'letterer'),
    'separator' => _creatorBucketByRole(item, 'separator'),
    'layouts' => _creatorBucketByRole(item, 'layouts'),
    'translator' => _creatorBucketByRole(item, 'translator'),
    'plotter' => _creatorBucketByRole(item, 'plotter'),
    'scripter' => _creatorBucketByRole(item, 'scripter'),
    'cover_artist' => _creatorBucketByRole(item, 'cover'),
    'cover_penciller' => _creatorBucketByRole(item, 'cover penciller'),
    'cover_painter' => _creatorBucketByRole(item, 'cover painter'),
    'cover_inker' => _creatorBucketByRole(item, 'cover inker'),
    'cover_colorist' => _creatorBucketByRole(item, 'cover colorist'),
    'cover_separator' => _creatorBucketByRole(item, 'cover separator'),
    'editor' => _creatorBucketByRole(item, 'editor'),
    'editor_in_chief' => _creatorBucketByRole(item, 'editor in chief'),
    'foreword_author' => _creatorBucketByRole(item, 'foreword author'),
    'ghost_writer' => _creatorBucketByRole(item, 'ghost writer'),
    'illustrator' => _creatorBucketByRole(item, 'illustrator'),
    'location' => _locationBucket(source.locationPath),
    'ownership' => source.isOwned
        ? overrides.owned
        : source.isWishlisted
            ? overrides.wishlist
            : overrides.catalogOnly,
    'added_date' => _dateBucket(
        source.ownedItem?.createdAt ?? source.wishlistItem?.createdAt,
        'Unknown added date',
      ),
    'added_month' => _monthBucket(
        source.ownedItem?.createdAt ?? source.wishlistItem?.createdAt,
        fallback: 'Unknown added month',
      ),
    'added_year' => _yearBucket(
        source.ownedItem?.createdAt ?? source.wishlistItem?.createdAt,
        'Unknown added year',
      ),
    'collection_status' => _stringBucket(
        source.ownedItem?.collectionStatus,
        'No collection status',
      ),
    'title' => _titleBucket(dto.title),
    'grade' =>
      source.grade?.trim().isNotEmpty == true ? source.grade! : 'Ungraded',
    'condition' => source.condition?.trim().isNotEmpty == true
        ? source.condition!
        : 'No condition',
    'raw_or_slabbed' => 'Raw',
    'is_key_comic' => 'Not special',
    'image_type' => _imageTypeBucket(source),
    'modified_date' => formatCompactDate(source.updatedAt),
    'modified_month' => _monthBucket(source.updatedAt),
    'my_rating' => _ratingBucket(source.tracking.rating),
    'owner' => _ownerBucket(source),
    'reader' => _ownerBucket(source),
    'reading_status' => source.tracking.statusLabel,
    'completed' => _completedBucket(source),
    'completed_date' =>
      _dateBucket(source.tracking.completedAt, 'Unknown completed date'),
    'completed_month' => _monthBucket(
        source.tracking.completedAt,
        fallback: 'Unknown completed month',
      ),
    'completed_year' =>
      _yearBucket(source.tracking.completedAt, 'Unknown completed year'),
    'read_date' =>
      _dateBucket(source.tracking.completedAt, 'Unknown read date'),
    'read_month' => _monthBucket(
        source.tracking.completedAt,
        fallback: 'Unknown read month',
      ),
    'read_year' =>
      _yearBucket(source.tracking.completedAt, 'Unknown read year'),
    'is_signed' => source.ownedItem?.signedBy?.trim().isNotEmpty == true
        ? 'Signed'
        : 'Not signed',
    'signed_by' => _stringBucket(
        source.ownedItem?.signedBy,
        'Not signed',
      ),
    'purchase_date' => _dateBucket(
        source.ownedItem?.purchaseDate,
        'Unknown purchase date',
      ),
    'purchase_month' => _monthBucket(
        source.ownedItem?.purchaseDate,
        fallback: 'Unknown purchase month',
      ),
    'purchase_year' => _yearBucket(
        source.ownedItem?.purchaseDate,
        'Unknown purchase year',
      ),
    'purchase_store' =>
      _stringBucket(source.ownedItem?.purchaseStore, 'No purchase store'),
    'sold_date' => _dateBucket(source.ownedItem?.soldAt, 'Unknown sold date'),
    'sold_month' => _monthBucket(
        source.ownedItem?.soldAt,
        fallback: 'Unknown sold month',
      ),
    'sold_year' => _yearBucket(source.ownedItem?.soldAt, 'Unknown sold year'),
    'storage_device' => _stringBucket(
        source.ownedItem?.musicDetails?.storageDevice,
        'No storage device',
      ),
    'dust_jacket' =>
      pub['dust_jacket'] == true ? 'Has dust jacket' : 'No dust jacket',
    'subject' => _firstOrDefault(
        (pub['subjects'] as List?)?.map((e) => e.toString()).toList(),
        'No subject',
      ),
    'tags' => _firstOrDefault(
        source.ownedItem?.tags
            ?.split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        'No tags',
      ),
    'bag_board_date' => _dateBucket(
        null,
        'Unknown bag/board date',
      ),
    'bag_board_month' => _monthBucket(
        null,
        fallback: 'Unknown bag/board month',
      ),
    'bag_board_year' => _yearBucket(
        null,
        'Unknown bag/board year',
      ),
    'watch_date' =>
      _dateBucket(_latestWatchSession(source)?.watchedAt, 'Unknown watch date'),
    'watch_month' => _monthBucket(
        _latestWatchSession(source)?.watchedAt,
        fallback: 'Unknown watch month',
      ),
    'watch_year' => _yearBucket(
        _latestWatchSession(source)?.watchedAt,
        'Unknown watch year',
      ),
    'watched' => _watchedBucket(source),
    'watched_where' => _watchedWhereBucket(source),
    _ => _titleBucket(dto.title),
  };
}

const _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _imageTypeLabels = <String, String>{
  'front_cover': 'Front Cover',
  'back_cover': 'Back Cover',
  'auxiliary': 'Photos',
};

String _dateBucket(DateTime? value, String fallback) {
  return value == null ? fallback : formatCompactDate(value);
}

String _monthBucket(DateTime? value, {String fallback = 'Unknown month'}) {
  if (value == null) {
    return fallback;
  }
  final local = value.toLocal();
  return '${_monthNames[local.month - 1]} ${local.year}';
}

String _yearBucket(DateTime? value, String fallback) {
  return value == null ? fallback : value.toLocal().year.toString();
}

String _stringBucket(String? value, String fallback) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return fallback;
  }
  return normalized;
}

String _ratingBucket(int? rating) {
  if (rating == null || rating <= 0) {
    return 'No rating';
  }
  return rating.toString();
}

String _imageTypeBucket(ShelfEntry source) {
  final imageType = source.itemImages.firstOrNull?.imageType;
  if (imageType == null || imageType.trim().isEmpty) {
    return 'No image type';
  }
  return _imageTypeLabels[imageType] ?? imageType;
}

WatchSession? _latestWatchSession(ShelfEntry source) {
  return source.watchSessions.firstOrNull;
}

String _watchedBucket(ShelfEntry source) {
  final latestSession = _latestWatchSession(source);
  final tracking = source.tracking;
  final watched = latestSession != null ||
      tracking.completedAt != null ||
      tracking.status == MediaTrackingStatus.completed ||
      tracking.status == MediaTrackingStatus.repeating;
  return watched ? 'Watched' : 'Not watched';
}

String _completedBucket(ShelfEntry source) {
  final tracking = source.tracking;
  final completed = tracking.completedAt != null ||
      tracking.status == MediaTrackingStatus.completed ||
      tracking.status == MediaTrackingStatus.repeating;
  return completed ? 'Completed' : 'Not completed';
}

String _watchedWhereBucket(ShelfEntry source) {
  final label = _latestWatchSession(source)?.sourceType?.label;
  if (label == null || label.trim().isEmpty) {
    return 'Unknown watch source';
  }
  return label;
}

String _ownerBucket(ShelfEntry source) {
  final explicit = source.ownedItem?.ownerLabel?.trim();
  if (explicit != null && explicit.isNotEmpty) {
    return explicit;
  }
  final fallback = source.fallbackOwnerLabel?.trim();
  if (fallback != null && fallback.isNotEmpty) {
    return fallback;
  }
  return 'Unknown owner';
}

String _locationBucket(String? location) {
  final normalized = location?.trim();
  if (normalized == null || normalized.isEmpty) {
    return 'No location';
  }
  return normalized;
}

String _firstOrDefault(List<String>? values, String fallback) {
  if (values == null || values.isEmpty) return fallback;
  final first = values.first.trim();
  return first.isEmpty ? fallback : first;
}

String _editionFormatBucket(LibraryProjectionRuntime item) {
  for (final CatalogEditionDto edition
      in item.source.catalogItem?.editions ?? const []) {
    final label = edition.physicalFormatLabel ?? edition.physicalFormat;
    if (label != null && label.trim().isNotEmpty) {
      return label.trim();
    }
  }
  return 'Unknown format';
}

String _movieOrTvSeriesBucket(LibraryProjectionRuntime item) {
  final normalizedMediaType =
      (item.source.catalogItem?.kind ?? '').trim().toLowerCase();
  if (normalizedMediaType == 'tv') {
    return 'TV Series';
  }
  if (item.dto.seriesTitle != null) {
    return 'TV Series';
  }
  return 'Movie';
}

CatalogEdition? _referenceEditionForEntry(LibraryProjectionRuntime item) {
  return item.source.catalogItem?.editions.firstOrNull;
}

String? _referenceRegionFor(ShelfEntry source, LibraryProjectionRuntime item) {
  final editionRegion = _referenceEditionForEntry(item)?.region?.trim();
  if (editionRegion != null && editionRegion.isNotEmpty) {
    return editionRegion;
  }
  final video = source.ownedItem?.videoLikeDetails;
  final ownedRegion = video?.region?.trim();
  if (ownedRegion != null && ownedRegion.isNotEmpty) {
    return ownedRegion;
  }
  return null;
}

String _creatorBucketByRole(LibraryProjectionRuntime item, String? role) {
  final creator = item.dto.creator;
  if (creator != null && creator.trim().isNotEmpty) {
    return creator.trim();
  }
  return role != null ? 'Unknown $role' : 'Unknown creator';
}

String _seriesBucket(LibraryProjectionRuntime item, String unknownLabel) {
  final seriesTitle = item.dto.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return unknownLabel;
}

String _titleBucket(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Unknown' : trimmed.substring(0, 1).toUpperCase();
}
