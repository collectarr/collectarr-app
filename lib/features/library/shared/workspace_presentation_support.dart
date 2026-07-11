import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/utils/text_utils.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

String defaultLibraryBucketLabel(
    LibraryBucketingContext context, LibraryMediaGroupLabels labels,
    [LibraryBucketLabelOverrides overrides =
        const LibraryBucketLabelOverrides()]) {
  final entry = context.entry;
  final source = context.source;
  final publisher = entry.publisher?.trim();
  return switch (context.groupMode) {
    'series' => _seriesBucket(entry, labels.unknownSeries),
    'story_arc' => overrides.storyArc,
    'character' => overrides.character,
    'year' => entry.releaseYear?.toString() ??
        (entry.releaseDate?.year.toString() ?? 'Unknown year'),
    'audience_rating' =>
      entry.audienceRating?.trim().isNotEmpty == true
          ? entry.audienceRating!
          : 'No audience rating',
    'color' => _stringBucket(entry.video?.color, 'No color'),
    'publisher' => publisher == null || publisher.isEmpty
        ? labels.unknownPublisher
        : publisher,
    'genre' => _firstOrDefault(entry.genres, overrides.noGenre),
    'platform' => _firstOrDefault(
        entry.game?.platforms ?? entry.rawPlatforms, 'No platform'),
    'developer' => _creatorBucketByRole(entry, 'developer'),
    'country' => entry.country?.trim().isNotEmpty == true
        ? entry.country!
        : overrides.unknownCountry,
    'language' => entry.language?.trim().isNotEmpty == true
        ? entry.language!
        : overrides.unknownLanguage,
    'age_rating' =>
      entry.ageRating?.trim().isNotEmpty == true ? entry.ageRating! : 'Unrated',
    'crossover' =>
      _stringBucket(entry.crossover, 'No crossover'),
    'imprint' =>
      _stringBucket(entry.publishing?.imprint, 'No imprint'),
    'series_group' =>
      _stringBucket(entry.publishing?.seriesGroup, 'No series group'),
    'movie_or_tv_series' => _movieOrTvSeriesBucket(entry),
    'release_date' =>
      _dateBucket(entry.releaseDate, 'Unknown release date'),
    'release_month' =>
      _monthBucket(entry.releaseDate, fallback: 'Unknown release month'),
    'release_year' => _yearBucket(
        entry.releaseDate ??
            (entry.releaseYear == null ? null : DateTime(entry.releaseYear!)),
        'Unknown release year',
      ),
    'publication_place' => _stringBucket(
        entry.publishing?.publicationPlace, 'Unknown publication place'),
    'original_release_date' => _dateBucket(
        entry.music?.originalReleaseDate,
        'Unknown original release date',
      ),
    'original_release_month' => _monthBucket(
        entry.music?.originalReleaseDate,
        fallback: 'Unknown original release month',
      ),
    'original_release_year' => _yearBucket(
        entry.music?.originalReleaseDate,
        'Unknown original release year',
      ),
    'original_country' => _stringBucket(
        entry.publishing?.originalCountry, 'Unknown original country'),
    'original_language' => _stringBucket(
        entry.publishing?.originalLanguage, 'Unknown original language'),
    'original_publication_date' => _dateBucket(
        entry.publishing?.originalPublicationDate,
        'Unknown original publication date',
      ),
    'original_publication_month' => _monthBucket(
        entry.publishing?.originalPublicationDate,
        fallback: 'Unknown original publication month',
      ),
    'original_publication_year' => _yearBucket(
        entry.publishing?.originalPublicationDate,
        'Unknown original publication year',
      ),
    'original_publication_place' => _stringBucket(
        entry.publishing?.originalPublicationPlace,
        'Unknown original publication place',
      ),
    'original_publisher' => _stringBucket(
        entry.publishing?.originalPublisher,
        'Unknown original publisher',
      ),
    'recording_date' => _dateBucket(
        entry.music?.recordingDate,
        'Unknown recording date',
      ),
    'recording_month' => _monthBucket(
        entry.music?.recordingDate,
        fallback: 'Unknown recording month',
      ),
    'recording_year' => _yearBucket(
        entry.music?.recordingDate,
        'Unknown recording year',
      ),
    'cover_date' =>
      _dateBucket(entry.coverDate, 'Unknown cover date'),
    'cover_month' =>
      _monthBucket(entry.coverDate, fallback: 'Unknown cover month'),
    'cover_year' =>
      _yearBucket(entry.coverDate, 'Unknown cover year'),
    'audio_tracks' =>
      _stringBucket(entry.video?.audioTracks, 'No audio tracks'),
    'box_set' =>
      _stringBucket(source.ownedItem?.boxSetName, 'No box set'),
    'completeness' =>
      _stringBucket(source.ownedItem?.gameCompleteness, 'No completeness'),
    'value_locked' =>
      source.ownedItem?.gameValueIsLocked == true ? 'Locked' : 'Unlocked',
    'dust_jacket_condition' => _stringBucket(
        entry.publishing?.dustJacketCondition, 'No dust jacket condition'),
    'distributor' =>
      _stringBucket(source.ownedItem?.distributor, 'No distributor'),
    'instrument' =>
      _stringBucket(entry.music?.instrument, 'No instrument'),
    'is_live' =>
      entry.music?.isLive == true ? 'Live' : 'Not live',
    'media_condition' =>
      _stringBucket(entry.music?.mediaCondition, 'No media condition'),
    'rpm' => _stringBucket(entry.music?.rpm, 'No RPM'),
    'spars' => _stringBucket(entry.music?.spars, 'No SPARS'),
    'sound_type' =>
      _stringBucket(entry.music?.soundType, 'No sound'),
    'studio' => _stringBucket(entry.music?.studio, 'No studio'),
    'vinyl_color' =>
      _stringBucket(entry.music?.vinylColor, 'No vinyl color'),
    'toy_subtype' =>
      _stringBucket(entry.game?.toySubtype, 'No subtype'),
    'toy_type' => _stringBucket(entry.game?.toyType, 'No type'),
    'edition' =>
      _stringBucket(entry.variant ?? entry.referenceEditionId, 'No edition'),
    'audiobook_abridged' =>
      entry.publishing?.audiobookAbridged == true
          ? 'Abridged'
          : 'Unabridged / Unknown',
    'first_edition' => entry.publishing?.firstEdition == true
        ? 'First edition'
        : 'Not first edition',
    'narrator' => _creatorBucketByRole(entry, 'narrator'),
    'paper_type' =>
      _stringBucket(entry.publishing?.paperType, 'No paper type'),
    'printed_by' =>
      _stringBucket(entry.publishing?.printedBy, 'No printer'),
    'edition_release_date' => _dateBucket(
        _referenceEditionForEntry(entry)?.releaseDate,
        'Unknown edition release date',
      ),
    'edition_release_month' => _monthBucket(
        _referenceEditionForEntry(entry)?.releaseDate,
        fallback: 'Unknown edition release month',
      ),
    'edition_release_year' => _yearBucket(
        _referenceEditionForEntry(entry)?.releaseDate,
        'Unknown edition release year',
      ),
    'extras' =>
      _stringBucket(source.ownedItem?.features, 'No extras'),
    'format' => _editionFormatBucket(entry),
    'hdr' =>
      _firstOrDefault(source.ownedItem?.hdrFormats, 'No HDR'),
    'layers' => _stringBucket(entry.video?.layers, 'No layers'),
    'packaging' =>
      _stringBucket(source.ownedItem?.packaging, 'No packaging'),
    'regions' =>
      _stringBucket(_referenceRegionFor(source, entry), 'No region'),
    'screen_ratios' =>
      _stringBucket(entry.video?.screenRatio, 'No screen ratio'),
    'subtitles' =>
      _stringBucket(entry.video?.subtitles, 'No subtitles'),
    'actor' => _creatorBucketByRole(entry, 'actor'),
    'chorus' => _creatorBucketByRole(entry, 'chorus'),
    'composer' => _creatorBucketByRole(entry, 'composer'),
    'composition' =>
      _stringBucket(entry.music?.composition, 'No composition'),
    'conductor' => _creatorBucketByRole(entry, 'conductor'),
    'engineer' => _creatorBucketByRole(entry, 'engineer'),
    'director' => _creatorBucketByRole(entry, 'director'),
    'musician' => _creatorBucketByRole(entry, 'musician'),
    'orchestra' => _creatorBucketByRole(entry, 'orchestra'),
    'photography' => _creatorBucketByRole(entry, 'photography'),
    'producer' => _creatorBucketByRole(entry, 'producer'),
    'creator' => _creatorBucketByRole(entry, null),
    'writer' => _creatorBucketByRole(entry, 'writer'),
    'artist' => _creatorBucketByRole(entry, 'artist'),
    'penciller' => _creatorBucketByRole(entry, 'penciller'),
    'inker' => _creatorBucketByRole(entry, 'inker'),
    'colorist' => _creatorBucketByRole(entry, 'colorist'),
    'painter' => _creatorBucketByRole(entry, 'painter'),
    'letterer' => _creatorBucketByRole(entry, 'letterer'),
    'separator' => _creatorBucketByRole(entry, 'separator'),
    'layouts' => _creatorBucketByRole(entry, 'layouts'),
    'translator' => _creatorBucketByRole(entry, 'translator'),
    'plotter' => _creatorBucketByRole(entry, 'plotter'),
    'scripter' => _creatorBucketByRole(entry, 'scripter'),
    'cover_artist' => _creatorBucketByRole(entry, 'cover'),
    'cover_penciller' =>
      _creatorBucketByRole(entry, 'cover penciller'),
    'cover_painter' =>
      _creatorBucketByRole(entry, 'cover painter'),
    'cover_inker' => _creatorBucketByRole(entry, 'cover inker'),
    'cover_colorist' =>
      _creatorBucketByRole(entry, 'cover colorist'),
    'cover_separator' =>
      _creatorBucketByRole(entry, 'cover separator'),
    'editor' => _creatorBucketByRole(entry, 'editor'),
    'editor_in_chief' =>
      _creatorBucketByRole(entry, 'editor in chief'),
    'foreword_author' =>
      _creatorBucketByRole(entry, 'foreword author'),
    'ghost_writer' => _creatorBucketByRole(entry, 'ghost writer'),
    'illustrator' => _creatorBucketByRole(entry, 'illustrator'),
    'location' => _locationBucket(entry.locationPath),
    'ownership' => entry.isOwned
        ? overrides.owned
        : entry.isWishlisted
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
    'title' => _titleBucket(entry.resolvedTitle),
    'grade' =>
      entry.grade?.trim().isNotEmpty == true ? entry.grade! : 'Ungraded',
    'condition' => entry.condition?.trim().isNotEmpty == true
        ? entry.condition!
        : 'No condition',
    'raw_or_slabbed' =>
      entry.comic?.rawOrSlabbed?.trim().isNotEmpty == true
          ? entry.comic!.rawOrSlabbed!
          : 'Raw',
    'is_key_comic' =>
      entry.comic?.keyComic == true ? 'Key' : 'Not special',
    'image_type' => _imageTypeBucket(source),
    'modified_date' => formatCompactDate(entry.updatedAt),
    'modified_month' => _monthBucket(entry.updatedAt),
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
    'is_signed' =>
      source.ownedItem?.signedBy?.trim().isNotEmpty == true
          ? 'Signed'
          : 'Not signed',
    'signed_by' =>
      _stringBucket(source.ownedItem?.signedBy, 'Not signed'),
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
    'sold_date' =>
      _dateBucket(source.ownedItem?.soldAt, 'Unknown sold date'),
    'sold_month' => _monthBucket(
        source.ownedItem?.soldAt,
        fallback: 'Unknown sold month',
      ),
    'sold_year' =>
      _yearBucket(source.ownedItem?.soldAt, 'Unknown sold year'),
    'storage_device' =>
      _stringBucket(source.ownedItem?.storageDevice, 'No storage device'),
    'dust_jacket' => entry.publishing?.dustJacket == true
        ? 'Has dust jacket'
        : 'No dust jacket',
    'subject' =>
      _firstOrDefault(entry.publishing?.subjects, 'No subject'),
    'tags' => _firstOrDefault(
        entry.tags
            ?.split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        'No tags',
      ),
    'bag_board_date' => _dateBucket(
        entry.lastBagBoardDate,
        'Unknown bag/board date',
      ),
    'bag_board_month' => _monthBucket(
        entry.lastBagBoardDate,
        fallback: 'Unknown bag/board month',
      ),
    'bag_board_year' => _yearBucket(
        entry.lastBagBoardDate,
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
    _ => _titleBucket(entry.resolvedTitle),
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

String _editionFormatBucket(LibraryWorkspaceEntry entry) {
  for (final edition in entry.editions) {
    final label = edition.physicalFormatLabel ?? edition.physicalFormat;
    if (label != null && label.trim().isNotEmpty) {
      return label.trim();
    }
  }
  return 'Unknown format';
}

String _movieOrTvSeriesBucket(LibraryWorkspaceEntry entry) {
  final normalizedMediaType = entry.mediaType.trim().toLowerCase();
  if (normalizedMediaType == 'tv') {
    return 'TV Series';
  }
  final series = entry.series;
  if (series?.seasonNumber != null || series?.episodeNumber != null) {
    return 'TV Series';
  }
  return 'Movie';
}

CatalogEdition? _referenceEditionForEntry(LibraryWorkspaceEntry entry) {
  final resolved = resolveLibraryEntryReferenceRelease(entry);
  return resolved.edition ??
      (entry.editions.isEmpty ? null : entry.editions.first);
}

String? _referenceRegionFor(ShelfEntry source, LibraryWorkspaceEntry entry) {
  final resolved = resolveLibraryEntryReferenceRelease(entry);
  final variantRegion = resolved.variant?.region?.trim();
  if (variantRegion != null && variantRegion.isNotEmpty) {
    return variantRegion;
  }
  final editionRegion = _referenceEditionForEntry(entry)?.region?.trim();
  if (editionRegion != null && editionRegion.isNotEmpty) {
    return editionRegion;
  }
  final ownedRegion = source.ownedItem?.region?.trim();
  if (ownedRegion != null && ownedRegion.isNotEmpty) {
    return ownedRegion;
  }
  return null;
}

String _creatorBucketByRole(LibraryWorkspaceEntry entry, String? role) {
  for (final credit in entry.creators ?? const <Map<String, dynamic>>[]) {
    final name = credit['name']?.toString().trim();
    if (name == null || name.isEmpty) continue;
    if (role == null) return name;
    final creditRole = credit['role']?.toString().toLowerCase().trim();
    if (creditRole != null && _matchesCreatorRole(creditRole, role)) {
      return name;
    }
  }
  return role != null ? 'Unknown $role' : 'Unknown creator';
}

bool _matchesCreatorRole(String creditRole, String role) {
  return switch (role) {
    'actor' => creditRole.contains('actor') || creditRole.contains('cast'),
    'musician' => creditRole.contains('musician') ||
        creditRole.contains('music') ||
        creditRole.contains('composer'),
    'photography' => creditRole.contains('photography') ||
        creditRole.contains('director of photography') ||
        creditRole.contains('cinemat'),
    'artist' => creditRole.contains('artist') && !creditRole.contains('cover'),
    'painter' => creditRole.contains('paint') && !creditRole.contains('cover'),
    'cover penciller' => creditRole.contains('cover') &&
        (creditRole.contains('pencil') || creditRole.contains('penciller')),
    'cover painter' =>
      creditRole.contains('cover') && creditRole.contains('paint'),
    'cover inker' => creditRole.contains('cover') && creditRole.contains('ink'),
    'cover colorist' =>
      creditRole.contains('cover') && creditRole.contains('color'),
    'cover separator' =>
      creditRole.contains('cover') && creditRole.contains('separator'),
    'editor in chief' => creditRole.contains('editor in chief') ||
        creditRole.contains('editor-in-chief'),
    _ => creditRole.contains(role),
  };
}

String _seriesBucket(LibraryWorkspaceEntry entry, String unknownLabel) {
  final seriesTitle = entry.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return unknownLabel;
}

String _titleBucket(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Unknown' : trimmed.substring(0, 1).toUpperCase();
}
