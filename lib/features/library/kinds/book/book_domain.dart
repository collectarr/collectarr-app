import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item_types.dart';

final class BookVariant {
  const BookVariant({
    required this.id,
    required this.name,
    this.variantType,
    this.sku,
    this.barcode,
    this.isbn,
    this.region,
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
  final String? sku;
  final String? barcode;
  final String? isbn;
  final String? region;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? description;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final bool isPrimary;
}

final class BookEdition {
  const BookEdition({
    required this.id,
    required this.title,
    this.format,
    this.publisher,
    this.isbn,
    this.upc,
    this.language,
    this.region,
    this.releaseDate,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.dimensions,
    this.dustJacket,
    this.printing,
    this.firstEdition = false,
    this.numberLine,
    this.coverImagePath,
    this.thumbnailImagePath,
    this.backImagePath,
    this.variants = const <BookVariant>[],
  });

  final String id;
  final String title;
  final String? format;
  final String? publisher;
  final String? isbn;
  final String? upc;
  final String? language;
  final String? region;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? dimensions;
  final bool? dustJacket;
  final String? printing;
  final bool firstEdition;
  final String? numberLine;
  final String? coverImagePath;
  final String? thumbnailImagePath;
  final String? backImagePath;
  final List<BookVariant> variants;

  factory BookEdition.fromDto(BookEditionDto dto) {
    return BookEdition(
      id: dto.id,
      title: dto.title,
      format: dto.format,
      publisher: dto.publisher,
      isbn: dto.isbn,
      upc: dto.upc,
      language: dto.language,
      region: dto.region,
      releaseDate: dto.releaseDate,
      dimensions: _stringField(dto.raw, 'dimensions'),
      dustJacket: _boolField(dto.raw, 'dust_jacket'),
      printing: _stringField(dto.raw, 'printing'),
      firstEdition: _boolField(dto.raw, 'first_edition') ?? false,
      numberLine: _stringField(dto.raw, 'number_line'),
      coverImagePath: _stringField(dto.raw, 'cover_image_path'),
      thumbnailImagePath: _stringField(dto.raw, 'thumbnail_image_path'),
      backImagePath: _stringField(dto.raw, 'back_image_path'),
    );
  }
}

final class BookOriginalDetails {
  const BookOriginalDetails({
    this.publisher,
    this.dewey,
    this.lccn,
    this.locControlNumber,
  });

  final String? publisher;
  final String? dewey;
  final String? lccn;
  final String? locControlNumber;

  bool get isEmpty =>
      publisher == null &&
      dewey == null &&
      lccn == null &&
      locControlNumber == null;
}

final class BookPhysicalDetails {
  const BookPhysicalDetails({
    this.dimensions,
    this.dustJacket,
    this.printing,
    this.firstEdition = false,
    this.numberLine,
    this.coverImagePath,
    this.thumbnailImagePath,
    this.backImagePath,
  });

  final String? dimensions;
  final bool? dustJacket;
  final String? printing;
  final bool firstEdition;
  final String? numberLine;
  final String? coverImagePath;
  final String? thumbnailImagePath;
  final String? backImagePath;

  bool get isEmpty =>
      dimensions == null &&
      dustJacket == null &&
      printing == null &&
      !firstEdition &&
      numberLine == null &&
      coverImagePath == null &&
      thumbnailImagePath == null &&
      backImagePath == null;
}

final class BookWork {
  const BookWork({
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
    this.originalDetails,
    this.editions = const <BookEdition>[],
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
    this.physicalFormatLabel,
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
  final BookOriginalDetails? originalDetails;
  final List<BookEdition> editions;
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
  final String? physicalFormatLabel;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  String? get displayEditionLabel =>
      variant ?? (editions.isNotEmpty ? editions.first.title : null);

  bool get hasMissingCoreMetadata =>
      publisher == null &&
      releaseDate == null &&
      releaseYear == null &&
      displayCoverUrl == null &&
      displayEditionLabel == null;

  factory BookWork.fromDto(BookWorkDto dto) {
    final editions = [
      for (final edition in dto.editions) BookEdition.fromDto(edition),
    ];
    return BookWork(
      id: dto.id,
      title: dto.title,
      synopsis: dto.description,
      coverImageUrl: dto.coverImageUrl,
      thumbnailImageUrl: dto.thumbnailImageUrl,
      publisher: dto.publisherName,
      coverDate: dto.coverDateValue,
      releaseDate: dto.releaseDate,
      releaseYear: dto.releaseYearValue,
      barcode: dto.barcode,
      variant: dto.variantValue,
      crossover: dto.crossoverValue,
      searchAliases: List<String>.unmodifiable(dto.searchAliases),
      genres: List<String>.unmodifiable(dto.genres),
      series: dto.series.isEmpty
          ? null
          : CatalogSeriesDetails(seriesTitle: dto.series.first as String),
      publishing: editions.isEmpty && dto.physicalFormatLabelValue == null
          ? null
          : CatalogPublishingDetails(
              pageCount:
                  dto.editions.isEmpty ? null : dto.editions.first.pageCount,
              subtitle: dto.physicalFormatLabelValue,
              originalLanguage: dto.languageValue,
              originalPublicationDate: dto.releaseDate,
              originalPublisher: dto.publisherName,
              subjects: List<String>.unmodifiable(dto.genres),
            ),
      originalDetails: _bookOriginalDetailsFromDto(dto),
      editions: editions,
      plotSummary: dto.plotSummaryValue,
      plotDescription: dto.plotDescriptionValue,
      creators: dto.creatorValues.isEmpty
          ? null
          : List<Map<String, dynamic>>.unmodifiable(dto.creatorValues),
      characters: List<String>.unmodifiable(dto.characterNames),
      storyArcs: List<String>.unmodifiable(dto.storyArcNames),
      country: dto.countryValue,
      language: dto.languageValue,
      ageRating: dto.ageRatingValue,
      audienceRating: dto.audienceRatingValue,
      physicalFormatLabel: dto.physicalFormatLabelValue,
    );
  }
}

BookOriginalDetails? _bookOriginalDetailsFromDto(BookWorkDto dto) {
  final raw = dto.raw;
  final originalDetails = raw['original_details'];
  if (originalDetails is Map<String, dynamic>) {
    final details = BookOriginalDetails(
      publisher: _stringField(originalDetails, 'publisher') ??
          _stringField(originalDetails, 'original_publisher'),
      dewey: _stringField(originalDetails, 'dewey'),
      lccn: _stringField(originalDetails, 'lccn'),
      locControlNumber: _stringField(originalDetails, 'loc_control_number') ??
          _stringField(originalDetails, 'locControlNumber'),
    );
    if (!details.isEmpty) {
      return details;
    }
  }
  final details = BookOriginalDetails(
    publisher: _stringField(raw, 'original_publisher') ?? dto.publisherName,
    dewey: _stringField(raw, 'dewey'),
    lccn: _stringField(raw, 'lccn'),
    locControlNumber: _stringField(raw, 'loc_control_number') ??
        _stringField(raw, 'locControlNumber'),
  );
  return details.isEmpty ? null : details;
}

String? _stringField(Map<String, dynamic> raw, String key) {
  final value = raw[key];
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

bool? _boolField(Map<String, dynamic> raw, String key) {
  final value = raw[key];
  if (value is bool) {
    return value;
  }
  final text = value?.toString().trim().toLowerCase();
  if (text == null || text.isEmpty) {
    return null;
  }
  if (text == 'true' || text == '1' || text == 'yes') {
    return true;
  }
  if (text == 'false' || text == '0' || text == 'no') {
    return false;
  }
  return null;
}
