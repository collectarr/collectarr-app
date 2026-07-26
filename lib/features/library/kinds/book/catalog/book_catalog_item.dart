import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';

/// Optional local-storage paths for physical book cover images.
class BookPhysicalDetails {
  const BookPhysicalDetails({
    this.coverImagePath,
    this.thumbnailImagePath,
    this.backImagePath,
    this.dimensions,
    this.printing,
    this.firstEdition,
    this.dustJacket,
    this.numberLine,
  });

  final String? coverImagePath;
  final String? thumbnailImagePath;
  final String? backImagePath;
  final String? dimensions;
  final String? printing;
  final bool? firstEdition;
  final bool? dustJacket;
  final String? numberLine;
}

/// Original publication details carried on a book catalog item.
class BookOriginalDetails {
  const BookOriginalDetails({
    this.originalTitle,
    this.originalPublisher,
    this.originalLanguage,
    this.originalCountry,
    this.originalPublicationDate,
    this.originalPublicationPlace,
    this.dewey,
    this.lccn,
    this.locControlNumber,
  });

  final String? originalTitle;
  final String? originalPublisher;
  final String? originalLanguage;
  final String? originalCountry;
  final DateTime? originalPublicationDate;
  final String? originalPublicationPlace;
  final String? dewey;
  final String? lccn;
  final String? locControlNumber;

  String? get publisher => originalPublisher;
}

class BookSeriesRef {
  const BookSeriesRef({
    required this.seriesId,
    required this.seriesTitle,
    this.volumeNumber,
    this.seriesGroup,
  });

  final String seriesId;
  final String seriesTitle;
  final double? volumeNumber;
  final String? seriesGroup;
}

class BookCreatorCredit {
  const BookCreatorCredit({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;
}

class BookWorkMetadata {
  const BookWorkMetadata({
    required this.title,
    this.subtitle,
    this.originalTitle,
    this.synopsis,
    this.originalCountry,
    this.originalLanguage,
    this.originalPublicationDate,
    this.originalPublicationPlace,
    this.originalPublisher,
    this.series,
    this.creators = const [],
    this.subjects = const [],
    this.genres = const [],
  });

  final String title;
  final String? subtitle;
  final String? originalTitle;
  final String? synopsis;
  final String? originalCountry;
  final String? originalLanguage;
  final DateTime? originalPublicationDate;
  final String? originalPublicationPlace;
  final String? originalPublisher;
  final BookSeriesRef? series;
  final List<BookCreatorCredit> creators;
  final List<String> subjects;
  final List<String> genres;
}

class BookPublishingMetadata {
  const BookPublishingMetadata({
    this.pageCount,
    this.imprint,
    this.publicationPlace,
    this.paperType,
    this.printedBy,
    this.dustJacket,
    this.dustJacketCondition,
    this.firstEdition,
    this.audiobookAbridged,
    this.coverPriceCents,
    this.currency,
  });

  final int? pageCount;
  final String? imprint;
  final String? publicationPlace;
  final String? paperType;
  final String? printedBy;
  final bool? dustJacket;
  final String? dustJacketCondition;
  final bool? firstEdition;
  final bool? audiobookAbridged;
  final int? coverPriceCents;
  final String? currency;
}

class BookCatalogItem {
  const BookCatalogItem({
    required this.id,
    required this.work,
    required this.publishing,
    required this.releases,
  });

  static BookCatalogItem fromDto(CatalogItemDto dto) =>
      BookCatalogMapper.mapDtoToBook(dto);

  final String id;
  final BookWorkMetadata work;
  final BookPublishingMetadata publishing;
  final List<BookRelease> releases;

  BookRelease? get primaryRelease => releases.isEmpty ? null : releases.first;
  String get title => work.title;
  String? get originalTitle => work.originalTitle;
  String? get synopsis => work.synopsis;
  String? get country => work.originalCountry;
  String? get language => work.originalLanguage;
  String? get ageRating => null;
  String? get audienceRating => null;
  List<Map<String, dynamic>>? get creators =>
      work.creators.map((c) => {'name': c.name, 'role': c.role}).toList();
  List<String>? get genres => work.genres;
  String? get plotSummary => null;
  String? get plotDescription => null;
  List<BookRelease> get chapters => releases;
  String? get displayEditionLabel => primaryRelease?.title;
  List<String>? get characters => null;
  List<String>? get storyArcs => null;
  List<TrailerLink>? get trailerUrls => const [];
  String? get crossover => null;
  String? get displayCoverUrl => primaryRelease?.coverImageUrl;
  String? get physicalFormatLabel => primaryRelease?.physicalFormatLabel;
  DateTime? get coverDate => primaryRelease?.releaseDate;
  DateTime? get releaseDate => primaryRelease?.releaseDate;
  int? get releaseYear => primaryRelease?.releaseDate?.year;
  String? get barcode => primaryRelease?.upc;
  String? get itemNumber => null;
  String? get publisher => primaryRelease?.publisher;
  String? get coverImageUrl => primaryRelease?.coverImageUrl;
  String? get thumbnailImageUrl => primaryRelease?.coverImageUrl;
  List<BookRelease> get editions => releases;
  BookOriginalDetails? get originalDetails => work.originalTitle != null ||
          work.originalPublisher != null ||
          work.originalLanguage != null ||
          work.originalCountry != null ||
          work.originalPublicationDate != null ||
          work.originalPublicationPlace != null
      ? BookOriginalDetails(
          originalTitle: work.originalTitle,
          originalPublisher: work.originalPublisher,
          originalLanguage: work.originalLanguage,
          originalCountry: work.originalCountry,
          originalPublicationDate: work.originalPublicationDate,
          originalPublicationPlace: work.originalPublicationPlace,
        )
      : null;
  String get displayTitle => work.title;
  String? get localizedTitle => null;
  List<String>? get searchAliases => null;
}
