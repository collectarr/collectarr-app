import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';

class ComicWorkMetadata {
  const ComicWorkMetadata({
    required this.title,
    this.issueNumber,
    this.synopsis,
    this.coverDate,
    this.series,
    this.creators = const [],
    this.characters = const [],
    this.storyArcs = const [],
    this.genres = const [],
  });

  final String title;
  final String? issueNumber;
  final String? synopsis;
  final DateTime? coverDate;
  final CatalogSeriesDetails? series;
  final List<String> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;
}

class ComicPublishingMetadata {
  const ComicPublishingMetadata({
    this.pageCount,
    this.coverPriceCents,
    this.currency,
    this.publisher,
    this.imprint,
    this.subtitle,
  });

  final int? pageCount;
  final int? coverPriceCents;
  final String? currency;
  final String? publisher;
  final String? imprint;
  final String? subtitle;
}

class ComicCatalogItem {
  const ComicCatalogItem({
    required this.id,
    required this.work,
    required this.publishing,
    required this.releases,
  });

  final String id;
  final ComicWorkMetadata work;
  final ComicPublishingMetadata publishing;
  final List<ComicRelease> releases;

  static ComicCatalogItem fromDto(CatalogItemDto dto) =>
      ComicCatalogMapper.mapDtoToComic(dto);

  ComicRelease? get primaryRelease => releases.isEmpty ? null : releases.first;
  String get title => work.title;
  String? get displayTitle => work.title;
  String? get localizedTitle => null;
  String? get originalTitle => null;
  String? get synopsis => work.synopsis;
  String? get itemNumber => work.issueNumber;
  String? get coverImageUrl => primaryRelease?.coverImageUrl;
  String? get thumbnailImageUrl => primaryRelease?.coverImageUrl;
  String? get publisher => publishing.publisher ?? primaryRelease?.publisher;
  DateTime? get coverDate => work.coverDate;
  DateTime? get releaseDate => primaryRelease?.releaseDate;
  int? get releaseYear => releaseDate?.year ?? coverDate?.year;
  String? get barcode => primaryRelease?.upc ?? primaryRelease?.isbn;
  String? get variant => primaryRelease?.title;
  String? get crossover => null;
  String? get displayCoverUrl => coverImageUrl;
  bool get hasMissingCoreMetadata => work.title.isEmpty;
  List<TrailerLink> get trailerUrls => const [];
  String? get plotSummary => work.synopsis;
  String? get plotDescription => null;
  List<Map<String, dynamic>>? get creators =>
      work.creators.map((c) => {'name': c, 'role': 'creator'}).toList();
  List<String> get characters => work.characters;
  List<String> get storyArcs => work.storyArcs;
  List<String> get genres => work.genres;
  String? get country => null;
  String? get language => null;
  String? get ageRating => null;
  String? get audienceRating => null;
  List<ComicRelease> get issues => releases;
  List<int> get missingIssueNumbers => const [];
  CatalogSeriesDetails? get series => work.series;
}
