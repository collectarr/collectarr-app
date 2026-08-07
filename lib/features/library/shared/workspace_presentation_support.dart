import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
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
  final cat = source.catalogItem;
  final publisher = dto.publisher?.trim();
  return switch (context.groupMode) {
    'series' => _seriesBucket(item, labels.unknownSeries),
    'story_arc' => overrides.storyArc,
    'character' => overrides.character,
    'year' => dto.releaseDate?.year.toString() ?? 'Unknown year',
    'audience_rating' => dto.audienceRating?.trim().isNotEmpty == true
        ? dto.audienceRating!
        : 'No audience rating',
    'color' => _stringBucket(cat?.video?.color, 'No color'),
    'publisher' => publisher == null || publisher.isEmpty
        ? labels.unknownPublisher
        : publisher,
    'genre' => _firstOrDefault(cat?.genres, overrides.noGenre),
    'platform' => _firstOrDefault(cat?.game?.platforms, 'No platform'),
    'developer' => _creatorBucketByRole(item, 'developer'),
    'country' => dto.country?.trim().isNotEmpty == true
        ? dto.country!
        : overrides.unknownCountry,
    'language' => dto.language?.trim().isNotEmpty == true
        ? dto.language!
        : overrides.unknownLanguage,
    'age_rating' =>
      dto.ageRating?.trim().isNotEmpty == true ? dto.ageRating! : 'Unrated',
    'crossover' => _stringBucket(cat?.crossover, 'No crossover'),
    'imprint' => _stringBucket(cat?.publishing?.imprint, 'No imprint'),
    'series_group' =>
      _stringBucket(cat?.publishing?.seriesGroup, 'No series group'),
    'movie_or_tv_series' => _movieOrTvSeriesBucket(item),
    'release_date' => _dateBucket(dto.releaseDate, 'Unknown release date'),
    'release_month' =>
      _monthBucket(dto.releaseDate, fallback: 'Unknown release month'),
    'release_year' => _yearBucket(
        dto.releaseDate,
        'Unknown release year',
      ),
    'publication_place' => _stringBucket(
        cat?.publishing?.publicationPlace, 'Unknown publication place'),
    'original_release_date' => _dateBucket(
        cat?.music?.originalReleaseDate,
        'Unknown original release date',
      ),
    'original_release_month' => _monthBucket(
        cat?.music?.originalReleaseDate,
        fallback: 'Unknown original release month',
      ),
    'original_release_year' => _yearBucket(
        cat?.music?.originalReleaseDate,
        'Unknown original release year',
      ),
    'original_country' => _stringBucket(
        cat?.publishing?.originalCountry, 'Unknown original country'),
    'original_language' => _stringBucket(
        cat?.publishing?.originalLanguage, 'Unknown original language'),
    'original_publication_date' => _dateBucket(
        cat?.publishing?.originalPublicationDate,
        'Unknown original publication date',
      ),
    'original_publication_month' => _monthBucket(
        cat?.publishing?.originalPublicationDate,
        fallback: 'Unknown original publication month',
      ),
    'original_publication_year' => _yearBucket(
        cat?.publishing?.originalPublicationDate,
        'Unknown original publication year',
      ),
    'original_publication_place' => _stringBucket(
        cat?.publishing?.originalPublicationPlace,
        'Unknown original publication place',
      ),
    'original_publisher' => _stringBucket(
        cat?.publishing?.originalPublisher,
        'Unknown original publisher',
      ),
    'recording_date' => _dateBucket(
        cat?.music?.recordingDate,
        'Unknown recording date',
      ),
    'recording_month' => _monthBucket(
        cat?.music?.recordingDate,
        fallback: 'Unknown recording month',
      ),
    'recording_year' => _yearBucket(
        cat?.music?.recordingDate,
        'Unknown recording year',
      ),
    'cover_date' => _dateBucket(cat?.coverDate, 'Unknown cover date'),
    'cover_month' =>
      _monthBucket(cat?.coverDate, fallback: 'Unknown cover month'),
    'cover_year' => _yearBucket(cat?.coverDate, 'Unknown cover year'),
    'audio_tracks' => _stringBucket(cat?.video?.audioTracks, 'No audio tracks'),
    'box_set' => _stringBucket(
        (source.ownedItem?.typedDetails is VideoOwnedDetails
            ? (source.ownedItem!.typedDetails as VideoOwnedDetails).boxSetName
            : null),
        'No box set',
      ),
    'completeness' => _stringBucket(
        (source.ownedItem?.typedDetails is GameOwnedDetails
            ? (source.ownedItem!.typedDetails as GameOwnedDetails).completeness
            : null),
        'No completeness',
      ),
    'value_locked' => (source.ownedItem?.typedDetails is GameOwnedDetails &&
            (source.ownedItem!.typedDetails as GameOwnedDetails)
                    .valueIsLocked ==
                true)
        ? 'Locked'
        : 'Unlocked',
    'dust_jacket_condition' => _stringBucket(
        cat?.publishing?.dustJacketCondition, 'No dust jacket condition'),
    'distributor' => _stringBucket(
        (source.ownedItem?.typedDetails is VideoOwnedDetails
            ? (source.ownedItem!.typedDetails as VideoOwnedDetails).distributor
            : null),
        'No distributor',
      ),
    'instrument' => _stringBucket(cat?.music?.instrument, 'No instrument'),
    'is_live' => cat?.music?.isLive == true ? 'Live' : 'Not live',
    'media_condition' =>
      _stringBucket(cat?.music?.mediaCondition, 'No media condition'),
    'rpm' => _stringBucket(cat?.music?.rpm, 'No RPM'),
    'spars' => _stringBucket(cat?.music?.spars, 'No SPARS'),
    'sound_type' => _stringBucket(cat?.music?.soundType, 'No sound'),
    'studio' => _stringBucket(cat?.music?.studio, 'No studio'),
    'vinyl_color' => _stringBucket(cat?.music?.vinylColor, 'No vinyl color'),
    'toy_subtype' => _stringBucket(cat?.game?.toySubtype, 'No subtype'),
    'toy_type' => _stringBucket(cat?.game?.toyType, 'No type'),
    'edition' => _stringBucket(dto.variant ?? dto.editionLabel, 'No edition'),
    'audiobook_abridged' => cat?.publishing?.audiobookAbridged == true
        ? 'Abridged'
        : 'Unabridged / Unknown',
    'first_edition' => cat?.publishing?.firstEdition == true
        ? 'First edition'
        : 'Not first edition',
    'narrator' => _creatorBucketByRole(item, 'narrator'),
    'paper_type' => _stringBucket(cat?.publishing?.paperType, 'No paper type'),
    'printed_by' => _stringBucket(cat?.publishing?.printedBy, 'No printer'),
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
        (source.ownedItem?.typedDetails is VideoOwnedDetails
            ? (source.ownedItem!.typedDetails as VideoOwnedDetails).features
            : null),
        'No extras',
      ),
    'format' => _editionFormatBucket(item),
    'hdr' => _firstOrDefault(
        (source.ownedItem?.typedDetails is VideoOwnedDetails
            ? (source.ownedItem!.typedDetails as VideoOwnedDetails).hdrFormats
            : null),
        'No HDR',
      ),
    'layers' => _stringBucket(cat?.video?.layers, 'No layers'),
    'packaging' => _stringBucket(
        (source.ownedItem?.typedDetails is VideoOwnedDetails
            ? (source.ownedItem!.typedDetails as VideoOwnedDetails).packaging
            : null),
        'No packaging',
      ),
    'regions' => _stringBucket(_referenceRegionFor(source, item), 'No region'),
    'screen_ratios' =>
      _stringBucket(cat?.video?.screenRatio, 'No screen ratio'),
    'subtitles' => _stringBucket(cat?.video?.subtitles, 'No subtitles'),
    'actor' => _creatorBucketByRole(item, 'actor'),
    'chorus' => _creatorBucketByRole(item, 'chorus'),
    'composer' => _creatorBucketByRole(item, 'composer'),
    'composition' => _stringBucket(cat?.music?.composition, 'No composition'),
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
    'location' => _locationBucket(dto.locationPath),
    'ownership' => dto.isOwned
        ? overrides.owned
        : dto.isWishlisted
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
    'grade' => dto.grade?.trim().isNotEmpty == true ? dto.grade! : 'Ungraded',
    'condition' => dto.condition?.trim().isNotEmpty == true
        ? dto.condition!
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
    'is_signed' => (source.ownedItem?.typedDetails is ComicOwnedDetails
                    ? (source.ownedItem!.typedDetails as ComicOwnedDetails)
                        .signedBy
                    : null)
                ?.trim()
                .isNotEmpty ==
            true
        ? 'Signed'
        : 'Not signed',
    'signed_by' => _stringBucket(
        (source.ownedItem?.typedDetails is ComicOwnedDetails
            ? (source.ownedItem!.typedDetails as ComicOwnedDetails).signedBy
            : null),
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
        (source.ownedItem?.typedDetails is MusicOwnedDetails
            ? (source.ownedItem!.typedDetails as MusicOwnedDetails)
                .storageDevice
            : null),
        'No storage device',
      ),
    'dust_jacket' => cat?.publishing?.dustJacket == true
        ? 'Has dust jacket'
        : 'No dust jacket',
    'subject' => _firstOrDefault(cat?.publishing?.subjects, 'No subject'),
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
  final video = source.ownedItem?.typedDetails is VideoOwnedDetails
      ? source.ownedItem!.typedDetails as VideoOwnedDetails
      : null;
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
