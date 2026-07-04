import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item_types.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

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

  factory BookVariant.fromCatalogVariant(CatalogVariant variant) {
    return BookVariant(
      id: variant.id,
      name: variant.name,
      variantType: variant.variantType,
      sku: variant.sku,
      barcode: variant.barcode,
      isbn: variant.isbn,
      region: variant.region,
      coverImageUrl: variant.coverImageUrl,
      thumbnailImageUrl: variant.thumbnailImageUrl,
      description: variant.description,
      physicalFormat: variant.physicalFormat,
      physicalFormatLabel: variant.physicalFormatLabel,
      isPrimary: variant.isPrimary,
    );
  }
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
  final List<BookVariant> variants;

  factory BookEdition.fromCatalogEdition(CatalogEdition edition) {
    return BookEdition(
      id: edition.id,
      title: edition.title,
      format: edition.format,
      publisher: edition.publisher,
      isbn: edition.isbn,
      upc: edition.upc,
      language: edition.language,
      region: edition.region,
      releaseDate: edition.releaseDate,
      physicalFormat: edition.physicalFormat,
      physicalFormatLabel: edition.physicalFormatLabel,
      variants: [
        for (final variant in edition.variants)
          BookVariant.fromCatalogVariant(variant),
      ],
    );
  }

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
    );
  }
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
          : CatalogSeriesDetails(seriesTitle: dto.series.first),
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

  factory BookWork.fromLibraryMetadataItem(LibraryMetadataItem item) {
    final editions = [
      for (final edition in item.editions)
        BookEdition.fromCatalogEdition(edition),
    ];
    return BookWork(
      id: item.id,
      title: item.title,
      displayTitle: item.displayTitle,
      localizedTitle: item.localizedTitle,
      originalTitle: item.originalTitle,
      searchAliases: List<String>.unmodifiable(item.searchAliases ?? const []),
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
      editions: editions,
      trailerUrls: List<TrailerLink>.unmodifiable(item.trailerUrls),
      plotSummary: item.plotSummary,
      plotDescription: item.plotDescription,
      creators: item.creators == null
          ? null
          : List<Map<String, dynamic>>.unmodifiable(
              item.creators!
                  .map((value) => Map<String, dynamic>.unmodifiable(value)),
            ),
      characters: List<String>.unmodifiable(item.characters ?? const []),
      storyArcs: List<String>.unmodifiable(item.storyArcs ?? const []),
      genres: List<String>.unmodifiable(item.genres ?? const []),
      country: item.country,
      language: item.language,
      ageRating: item.ageRating,
      audienceRating: item.audienceRating,
      physicalFormatLabel: item.physicalFormatLabel,
    );
  }

}
