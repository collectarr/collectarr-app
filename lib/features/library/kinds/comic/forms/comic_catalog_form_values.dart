/// Catalog values shared by the Comic Add form and issue Edit schema.
final class ComicCatalogItemFormValues {
  ComicCatalogItemFormValues({
    this.title = '',
    this.seriesTitle = '',
    this.seriesId,
    this.issueNumber = '',
    this.variant = '',
    this.editionTitle = '',
    this.barcode = '',
    this.isbn = '',
    this.upc = '',
    this.physicalFormatLabel = '',
    this.coverDate,
    this.releaseDate,
    this.publisher = '',
    this.imprint = '',
    this.seriesGroup = '',
    this.pageCount,
    this.ageRating = '',
    this.genres = const [],
    this.language = '',
    this.country = '',
    this.crossover = '',
    this.storyArcs = const [],
    this.coverImageUrl = '',
  });

  String title;
  String seriesTitle;
  String? seriesId;
  String issueNumber;
  String variant;
  String editionTitle;
  String barcode;
  String isbn;
  String upc;
  String physicalFormatLabel;
  DateTime? coverDate;
  DateTime? releaseDate;
  String publisher;
  String imprint;
  String seriesGroup;
  int? pageCount;
  String ageRating;
  List<String> genres;
  String language;
  String country;
  String crossover;
  List<String> storyArcs;
  String coverImageUrl;
}

typedef ComicCatalogItemValuesReader<T> = ComicCatalogItemFormValues Function(T value);
