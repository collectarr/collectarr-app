import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

final class MangaChapter {
  const MangaChapter({
    required this.id,
    required this.title,
    this.chapterNumber,
    this.volumeNumber,
    this.releaseDate,
    this.barcode,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.isPrimary = false,
  });

  final String id;
  final String title;
  final String? chapterNumber;
  final String? volumeNumber;
  final DateTime? releaseDate;
  final String? barcode;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final bool isPrimary;

  factory MangaChapter.fromDtoValue(Object? value, {bool isPrimary = false}) {
    final json =
        value is Map<String, dynamic> ? value : const <String, dynamic>{};
    return MangaChapter(
      id: _stringOrEmpty(json['id'] ?? json['chapter_id'] ?? json['chapterId']),
      title: _stringOrNull(json['title']) ?? 'Chapter',
      chapterNumber:
          _stringOrNull(json['chapter_number'] ?? json['chapterNumber']),
      volumeNumber:
          _stringOrNull(json['volume_number'] ?? json['volumeNumber']),
      releaseDate: _dateOrNull(json['release_date'] ?? json['releaseDate']),
      barcode: _stringOrNull(json['barcode']),
      physicalFormat:
          _stringOrNull(json['physical_format'] ?? json['physicalFormat']),
      physicalFormatLabel: _stringOrNull(
        json['physical_format_label'] ?? json['physicalFormatLabel'],
      ),
      isPrimary: isPrimary,
    );
  }

  factory MangaChapter.fromCatalogEdition(
    CatalogEdition edition, {
    bool isPrimary = false,
  }) {
    return MangaChapter(
      id: edition.id,
      title: edition.title,
      releaseDate: edition.releaseDate,
      barcode: edition.upc ?? edition.isbn,
      physicalFormat: edition.physicalFormat,
      physicalFormatLabel: edition.physicalFormatLabel,
      isPrimary: isPrimary,
    );
  }

  CatalogEdition toCatalogEdition() {
    return CatalogEdition(
      id: id,
      title: title,
      releaseDate: releaseDate,
      upc: barcode,
      physicalFormat: physicalFormat,
      physicalFormatLabel: physicalFormatLabel,
    );
  }
}

final class MangaPersonalOverlay {
  const MangaPersonalOverlay({
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

  factory MangaPersonalOverlay.fromShelf(ShelfEntry source) {
    return MangaPersonalOverlay(
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
}

final class MangaWork {
  const MangaWork({
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
    this.chapters = const <MangaChapter>[],
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
    this.originalLanguage,
    this.subtitle,
    this.status,
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
  final List<MangaChapter> chapters;
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
  final String? originalLanguage;
  final String? subtitle;
  final String? status;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  String? get displayEditionLabel =>
      variant ?? (chapters.isNotEmpty ? chapters.first.title : null);

  bool get hasMissingCoreMetadata =>
      publisher == null &&
      releaseDate == null &&
      releaseYear == null &&
      displayCoverUrl == null &&
      displayEditionLabel == null;

  factory MangaWork.fromDto(MangaWorkDto dto) {
    return MangaWork(
      id: dto.id,
      title: dto.title,
      synopsis: dto.description,
      releaseDate: dto.releaseDate,
      releaseYear: dto.releaseDate?.year,
      originalLanguage: dto.originalLanguage,
      subtitle: _stringOrNull(dto.raw['subtitle']),
      status: _stringOrNull(dto.raw['status']),
      series: _seriesFromRaw(dto.raw),
      publishing: _publishingFromRaw(dto.raw),
      chapters: [
        for (var index = 0; index < dto.chapters.length; index++)
          MangaChapter.fromDtoValue(
            dto.chapters[index],
            isPrimary: index == 0,
          ),
      ],
      searchAliases: const <String>[],
      characters: const <String>[],
      storyArcs: const <String>[],
      genres: const <String>[],
    );
  }

  factory MangaWork.fromMetadataItem(LibraryMetadataItem item) {
    final chapters = [
      for (var index = 0; index < item.editions.length; index++)
        MangaChapter.fromCatalogEdition(
          item.editions[index],
          isPrimary: index == 0,
        ),
    ];
    return MangaWork(
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
      chapters: chapters,
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
      originalLanguage: item.language,
      subtitle: item.publishing?.subtitle,
      status: item.game?.toyType,
    );
  }
}

CatalogSeriesDetails? _seriesFromRaw(Map<String, dynamic> raw) {
  final details = CatalogSeriesDetails(
    seriesId: _stringOrNull(raw['series_id'] ?? raw['seriesId']),
    seriesTitle: _stringOrNull(raw['series_title'] ?? raw['seriesTitle']),
    volumeName: _stringOrNull(raw['volume_name'] ?? raw['volumeName']),
    volumeNumber: _doubleOrNull(raw['volume_number'] ?? raw['volumeNumber']),
    volumeStartYear:
        _intOrNull(raw['volume_start_year'] ?? raw['volumeStartYear']),
    tags: _stringList(raw['tags']),
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
    subjects: _stringList(raw['subjects']),
  );
  return details.hasData ? details : null;
}

String _stringOrEmpty(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? '' : text;
}

String? _stringOrNull(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return [
    for (final entry in value)
      if (entry != null && entry.toString().trim().isNotEmpty)
        entry.toString().trim(),
  ];
}

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _doubleOrNull(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _dateOrNull(Object? value) {
  final text = _stringOrNull(value);
  return text == null ? null : DateTime.tryParse(text);
}
