import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class ComicVariant {
  const ComicVariant({
    required this.id,
    required this.name,
    this.variantType,
    this.barcode,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.description,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String? variantType;
  final String? barcode;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? description;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final bool isPrimary;

  bool get hasMissingCover => coverImageUrl == null && thumbnailImageUrl == null;

  factory ComicVariant.fromJson(Map<String, dynamic> json) {
    return ComicVariant(
      id: _stringOrEmpty(json['id'] ?? json['variant_id'] ?? json['variantId']),
      name: _stringOrEmpty(json['name'] ?? json['title'] ?? json['label']) ==
              ''
          ? 'Variant'
          : _stringOrEmpty(json['name'] ?? json['title'] ?? json['label']),
      variantType: _stringOrNull(json['variant_type'] ?? json['variantType']),
      barcode: _stringOrNull(json['barcode']),
      coverImageUrl:
          _stringOrNull(json['cover_image_url'] ?? json['coverImageUrl']),
      thumbnailImageUrl:
          _stringOrNull(json['thumbnail_image_url'] ?? json['thumbnailImageUrl']),
      description: _stringOrNull(json['description']),
      physicalFormat:
          _stringOrNull(json['physical_format'] ?? json['physicalFormat']),
      physicalFormatLabel: _stringOrNull(
        json['physical_format_label'] ?? json['physicalFormatLabel'],
      ),
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  factory ComicVariant.fromCatalogEdition(
    CatalogEdition edition, {
    bool isPrimary = false,
  }) {
    return ComicVariant(
      id: edition.id,
      name: edition.title,
      variantType: edition.format,
      barcode: edition.upc ?? edition.isbn,
      physicalFormat: edition.physicalFormat,
      physicalFormatLabel: edition.physicalFormatLabel,
      isPrimary: isPrimary,
    );
  }
}

final class ComicIssue {
  const ComicIssue({
    required this.id,
    required this.issueNumber,
    this.title,
    this.description,
    this.releaseDate,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.barcode,
    this.variants = const <ComicVariant>[],
    this.creators,
    this.characters = const <String>[],
    this.storyArcs = const <String>[],
    this.genres = const <String>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String issueNumber;
  final String? title;
  final String? description;
  final DateTime? releaseDate;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? barcode;
  final List<ComicVariant> variants;
  final List<Map<String, dynamic>>? creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;
  final Map<String, dynamic> metadata;

  int? get issueNumberValue => _issueNumberValue(issueNumber);
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory ComicIssue.fromJson(Map<String, dynamic> json) {
    final variants = [
      for (final entry in _mapList(json['variants'] ?? json['editions']))
        ComicVariant.fromJson(entry),
    ];
    return ComicIssue(
      id: _stringOrEmpty(json['id'] ?? json['issue_id'] ?? json['issueId']),
      issueNumber: _stringOrEmpty(
        json['issue_number'] ?? json['issueNumber'] ?? json['number'],
      ),
      title: _stringOrNull(json['title']),
      description: _stringOrNull(json['description'] ?? json['plot_summary']),
      releaseDate: _dateOrNull(json['release_date'] ?? json['releaseDate']),
      coverImageUrl:
          _stringOrNull(json['cover_image_url'] ?? json['coverImageUrl']),
      thumbnailImageUrl:
          _stringOrNull(json['thumbnail_image_url'] ?? json['thumbnailImageUrl']),
      barcode: _stringOrNull(json['barcode']),
      variants: variants,
      creators: _mapList(json['creators']),
      characters: _stringList(json['characters']),
      storyArcs: _stringList(json['story_arcs'] ?? json['storyArcs']),
      genres: _stringList(json['genres']),
      metadata: _metadataMap(json),
    );
  }
}

final class ComicPersonalOverlay {
  const ComicPersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.updatedAt,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.labelType,
    this.certificationNumber,
    this.grade,
    this.signedBy,
    this.keyComic = false,
    this.keyReason,
    this.lastBagBoardDate,
  });

  factory ComicPersonalOverlay.fromShelf(ShelfEntry source) {
    return ComicPersonalOverlay(
      ownedItem: source.ownedItem,
      trackingEntry: source.trackingEntry,
      wishlistItem: source.wishlistItem,
      locationPath: source.locationPath,
      updatedAt: source.updatedAt,
      rawOrSlabbed: source.ownedItem?.rawOrSlabbed,
      gradingCompany: source.ownedItem?.gradingCompany,
      labelType: source.ownedItem?.labelType,
      certificationNumber: source.ownedItem?.certificationNumber,
      grade: source.ownedItem?.grade,
      signedBy: source.ownedItem?.signedBy,
      keyComic: source.ownedItem?.keyComic ?? false,
      keyReason: source.ownedItem?.keyReason,
      lastBagBoardDate: source.ownedItem?.lastBagBoardDate,
    );
  }

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? updatedAt;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? labelType;
  final String? certificationNumber;
  final String? grade;
  final String? signedBy;
  final bool keyComic;
  final String? keyReason;
  final DateTime? lastBagBoardDate;

  bool get isOwned => ownedItem != null;
  bool get isTracked => trackingEntry != null;
  bool get isWishlisted => wishlistItem != null;
  bool get isSlabbed => rawOrSlabbed?.trim().toLowerCase() == 'slabbed';

  ComicWorkspaceDetails? toWorkspaceDetails() {
    final details = ComicWorkspaceDetails(
      rawOrSlabbed: rawOrSlabbed,
      gradingCompany: gradingCompany,
      labelType: labelType,
      certificationNumber: certificationNumber,
      keyComic: keyComic,
      keyReason: keyReason,
    );
    return details.hasData ? details : null;
  }
}

final class ComicWork {
  const ComicWork({
    required this.id,
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.searchAliases = const <String>[],
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.publisher,
    this.coverDate,
    this.releaseDate,
    this.releaseYear,
    this.barcode,
    this.variant,
    this.crossover,
    this.series,
    this.publishing,
    this.issues = const <ComicIssue>[],
    this.trailerUrls = const <TrailerLink>[],
    this.plotSummary,
    this.plotDescription,
    this.creators,
    this.characters = const <String>[],
    this.storyArcs = const <String>[],
    this.genres = const <String>[],
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
  });

  final String id;
  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final List<String> searchAliases;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? publisher;
  final DateTime? coverDate;
  final DateTime? releaseDate;
  final int? releaseYear;
  final String? barcode;
  final String? variant;
  final String? crossover;
  final CatalogSeriesDetails? series;
  final CatalogPublishingDetails? publishing;
  final List<ComicIssue> issues;
  final List<TrailerLink> trailerUrls;
  final String? plotSummary;
  final String? plotDescription;
  final List<Map<String, dynamic>>? creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  String? get displayIssueLabel =>
      itemNumber ?? (issues.isNotEmpty ? issues.first.issueNumber : null);

  bool get hasMissingCoreMetadata =>
      publisher == null &&
      releaseDate == null &&
      releaseYear == null &&
      displayCoverUrl == null &&
      displayIssueLabel == null;

  List<int> get missingIssueNumbers => missingIssueNumbersFromIssues(issues);

  factory ComicWork.fromDto(ComicWorkDto dto) {
    return ComicWork(
      id: dto.id,
      title: dto.title,
      displayTitle: _stringOrNull(dto.raw['display_title']),
      localizedTitle: _stringOrNull(dto.raw['localized_title']),
      originalTitle: _stringOrNull(dto.raw['original_title']),
      searchAliases: _stringList(dto.raw['search_aliases']),
      itemNumber: _stringOrNull(dto.raw['item_number']),
      synopsis: _stringOrNull(dto.raw['synopsis']),
      coverImageUrl: _stringOrNull(dto.raw['cover_image_url']),
      thumbnailImageUrl: _stringOrNull(dto.raw['thumbnail_image_url']),
      publisher: _stringOrNull(dto.raw['publisher']),
      coverDate: _dateOrNull(dto.raw['cover_date']),
      releaseDate: dto.releaseDate,
      releaseYear: _intOrNull(dto.raw['release_year']),
      barcode: dto.barcode,
      variant: _stringOrNull(dto.raw['variant']),
      crossover: _stringOrNull(dto.raw['crossover']),
      series: _seriesFromRaw(dto.raw),
      publishing: _publishingFromRaw(dto.raw),
      issues: [
        for (final entry in _mapList(dto.issues)) ComicIssue.fromJson(entry),
      ],
      trailerUrls: [
        for (final entry in _mapList(dto.raw['trailer_urls'])) TrailerLink.fromJson(entry),
      ],
      plotSummary: _stringOrNull(dto.raw['plot_summary']),
      plotDescription: _stringOrNull(dto.raw['plot_description']),
      creators: _mapList(dto.raw['creators']),
      characters: _stringList(dto.raw['characters']),
      storyArcs: _stringList(dto.raw['story_arcs']),
      genres: _stringList(dto.raw['genres']),
      country: _stringOrNull(dto.raw['country']),
      language: dto.originalLanguage ?? _stringOrNull(dto.raw['language']),
      ageRating: _stringOrNull(dto.raw['age_rating']),
      audienceRating: _stringOrNull(dto.raw['audience_rating']),
    );
  }

  factory ComicWork.fromMetadataItem(LibraryMetadataItem item) {
    final issue = item.itemNumber?.trim().isNotEmpty == true
        ? ComicIssue(
            id: item.id,
            issueNumber: item.itemNumber!.trim(),
            title: item.displayEditionLabel ?? item.title,
            releaseDate: item.releaseDate,
            coverImageUrl: item.coverImageUrl,
            thumbnailImageUrl: item.thumbnailImageUrl,
            barcode: item.barcode,
            variants: [
              for (final edition in item.editions)
                ComicVariant.fromCatalogEdition(
                  edition,
                  isPrimary: edition.id == item.editions.firstOrNull?.id,
                ),
            ],
            creators: item.creators,
            characters: item.characters ?? const <String>[],
            storyArcs: item.storyArcs ?? const <String>[],
            genres: item.genres ?? const <String>[],
          )
        : null;
    return ComicWork(
      id: item.id,
      title: item.title,
      displayTitle: item.displayTitle,
      localizedTitle: item.localizedTitle,
      originalTitle: item.originalTitle,
      searchAliases: item.searchAliases ?? const <String>[],
      itemNumber: item.itemNumber,
      synopsis: item.synopsis,
      coverImageUrl: item.coverImageUrl,
      thumbnailImageUrl: item.thumbnailImageUrl,
      publisher: item.publisher,
      coverDate: item.coverDate,
      releaseDate: item.releaseDate,
      releaseYear: item.releaseYear,
      barcode: item.barcode,
      variant: item.variant,
      crossover: item.crossover,
      series: item.series,
      publishing: item.publishing,
      issues: issue == null ? const <ComicIssue>[] : [issue],
      trailerUrls: item.trailerUrls,
      plotSummary: item.plotSummary,
      plotDescription: item.plotDescription,
      creators: item.creators,
      characters: item.characters ?? const <String>[],
      storyArcs: item.storyArcs ?? const <String>[],
      genres: item.genres ?? const <String>[],
      country: item.country,
      language: item.language,
      ageRating: item.ageRating,
      audienceRating: item.audienceRating,
    );
  }

  factory ComicWork.fromWorkspaceEntry(LibraryWorkspaceEntry entry) {
    final issue = entry.itemNumber?.trim().isNotEmpty == true
        ? ComicIssue(
            id: entry.titleItemId ?? entry.id,
            issueNumber: entry.itemNumber!.trim(),
            title: entry.displayTitle ?? entry.title,
            releaseDate: entry.releaseDate,
            coverImageUrl: entry.coverImageUrl,
            thumbnailImageUrl: entry.thumbnailImageUrl,
            barcode: entry.barcode,
            variants: [
              for (final edition in entry.editions)
                ComicVariant.fromCatalogEdition(
                  edition,
                  isPrimary: edition.id == entry.referenceEditionId,
                ),
            ],
            creators: entry.creators,
            characters: entry.characters ?? const <String>[],
            storyArcs: entry.storyArcs ?? const <String>[],
            genres: entry.genres ?? const <String>[],
          )
        : null;
    return ComicWork(
      id: entry.titleItemId ?? entry.id,
      title: entry.title,
      displayTitle: entry.displayTitle,
      localizedTitle: entry.localizedTitle,
      originalTitle: entry.originalTitle,
      searchAliases: entry.searchAliases ?? const <String>[],
      itemNumber: entry.itemNumber,
      synopsis: entry.synopsis,
      coverImageUrl: entry.coverImageUrl,
      thumbnailImageUrl: entry.thumbnailImageUrl,
      publisher: entry.publisher,
      coverDate: entry.coverDate,
      releaseDate: entry.releaseDate,
      releaseYear: entry.releaseYear,
      barcode: entry.barcode,
      variant: entry.variant,
      crossover: entry.crossover,
      series: entry.series,
      publishing: entry.publishing,
      issues: issue == null ? const <ComicIssue>[] : [issue],
      trailerUrls: entry.trailerUrls,
      plotSummary: entry.plotSummary,
      plotDescription: entry.plotDescription,
      creators: entry.creators,
      characters: entry.characters ?? const <String>[],
      storyArcs: entry.storyArcs ?? const <String>[],
      genres: entry.genres ?? const <String>[],
      country: entry.country,
      language: entry.language,
      ageRating: entry.ageRating,
      audienceRating: entry.audienceRating,
    );
  }

  static List<int> missingIssueNumbersFromIssues(List<ComicIssue> issues) {
    final numbers = issues
        .map((issue) => issue.issueNumberValue)
        .whereType<int>()
        .toSet()
        .toList(growable: false)
      ..sort();
    if (numbers.length < 2) {
      return const <int>[];
    }
    final missing = <int>[];
    for (var index = 1; index < numbers.length; index += 1) {
      final previous = numbers[index - 1];
      final current = numbers[index];
      for (var value = previous + 1; value < current; value += 1) {
        missing.add(value);
      }
    }
    return missing;
  }
}

extension on Iterable<CatalogEdition> {
  CatalogEdition? get firstOrNull => isEmpty ? null : first;
}

CatalogSeriesDetails? _seriesFromRaw(Map<String, dynamic> raw) {
  final seriesId = _stringOrNull(raw['series_id'] ?? raw['seriesId']);
  final seriesTitle = _stringOrNull(raw['series_title'] ?? raw['seriesTitle']);
  final volumeName = _stringOrNull(raw['volume_name'] ?? raw['volumeName']);
  final volumeNumber = _doubleOrNull(raw['volume_number'] ?? raw['volumeNumber']);
  final volumeStartYear = _intOrNull(
    raw['volume_start_year'] ?? raw['volumeStartYear'],
  );
  final seasonNumber = _intOrNull(raw['season_number'] ?? raw['seasonNumber']);
  final episodeNumber = _intOrNull(
    raw['episode_number'] ?? raw['episodeNumber'],
  );
  final tags = _stringList(raw['tags']);
  final details = CatalogSeriesDetails(
    seriesId: seriesId,
    seriesTitle: seriesTitle,
    volumeName: volumeName,
    volumeNumber: volumeNumber,
    volumeStartYear: volumeStartYear,
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
    tags: tags,
  );
  return details.hasData ? details : null;
}

CatalogPublishingDetails? _publishingFromRaw(Map<String, dynamic> raw) {
  final details = CatalogPublishingDetails(
    subtitle: _stringOrNull(raw['subtitle']),
    originalCountry: _stringOrNull(raw['country']),
    originalLanguage: _stringOrNull(raw['language']),
    originalPublicationDate: _dateOrNull(raw['original_publication_date']),
    originalPublisher: _stringOrNull(raw['publisher']),
    publicationPlace: _stringOrNull(raw['publication_place']),
    coverPriceCents: _intOrNull(raw['cover_price_cents']),
    currency: _stringOrNull(raw['currency']),
    subjects: _stringList(raw['subjects']),
  );
  return details.hasData ? details : null;
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

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return [
    for (final entry in value)
      if (entry != null && entry.toString().trim().isNotEmpty)
        entry.toString().trim(),
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

double? _doubleOrNull(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _dateOrNull(Object? value) {
  final text = _stringOrNull(value);
  return text == null ? null : DateTime.tryParse(text);
}

int? _issueNumberValue(String value) {
  final match = RegExp(r'^\s*(\d+)').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}
