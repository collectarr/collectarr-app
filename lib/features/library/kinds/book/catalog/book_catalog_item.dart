import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';
import 'package:collectarr_app/features/library/shared/book/book_domain.dart';

export 'package:collectarr_app/features/library/shared/book/book_domain.dart'
    show BookPhysicalDetails, BookOriginalDetails;

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
    this.characters = const [],
    this.storyArcs = const [],
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
  final List<String> characters;
  final List<String> storyArcs;
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
    this.dewey,
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
  final String? dewey;
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
  BookSeriesRef? get series => work.series;
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
  String? get plotSummary => work.synopsis;
  String? get plotDescription => null;
  List<BookRelease> get chapters => releases;
  List<BookRelease> get editions => releases;
  String? get displayEditionLabel => primaryRelease?.title;
  List<String>? get characters => work.characters;
  List<String>? get storyArcs => work.storyArcs;
  List<TrailerLink>? get trailerUrls => const [];
  String? get crossover => null;
  String? get displayCoverUrl => primaryRelease?.coverImageUrl;
  String? get physicalFormatLabel => primaryRelease?.physicalFormatLabel;
  DateTime? get coverDate => primaryRelease?.releaseDate;
  DateTime? get releaseDate => primaryRelease?.releaseDate;
  int? get releaseYear => primaryRelease?.releaseDate?.year;
  String? get barcode => primaryRelease?.upc ?? primaryRelease?.isbn;
  String? get itemNumber => null;
  String? get publisher => primaryRelease?.publisher;
  String? get coverImageUrl => primaryRelease?.coverImageUrl;
  String? get thumbnailImageUrl =>
      primaryRelease?.thumbnailImageUrl ?? primaryRelease?.coverImageUrl;
  BookOriginalDetails? get originalDetails => BookOriginalDetails(
        originalTitle: work.originalTitle,
        originalPublisher: work.originalPublisher,
        originalLanguage: work.originalLanguage,
        originalCountry: work.originalCountry,
        originalPublicationDate: work.originalPublicationDate,
        originalPublicationPlace: work.originalPublicationPlace,
        dewey: publishing.dewey,
      );
  String get displayTitle => work.title;
  String? get localizedTitle => null;
  List<String>? get searchAliases => null;
}
