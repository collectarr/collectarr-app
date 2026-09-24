/// Catalog values shared by the Comic Add form and issue Edit schema.
final class ComicMediaFormValues {
  ComicMediaFormValues({
    this.seriesTitle = '',
    this.seriesId,
    this.issueNumber = '',
    this.variant = '',
    this.editionTitle = '',
    this.barcode = '',
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

  String seriesTitle;
  String? seriesId;
  String issueNumber;
  String variant;
  String editionTitle;
  String barcode;
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

/// Values for a canonical Comic release; variants stay attached to the model.
final class ComicReleaseFormValues {
  ComicReleaseFormValues({
    this.id = '',
    this.title = '',
    this.publisher = '',
    this.imprint = '',
    this.isbn = '',
    this.upc = '',
    this.releaseDate,
    this.coverImageUrl = '',
  });

  final String id;
  String title;
  String publisher;
  String imprint;
  String isbn;
  String upc;
  DateTime? releaseDate;
  String coverImageUrl;
}

typedef ComicMediaValuesReader<T> = ComicMediaFormValues Function(T value);
typedef ComicReleaseValuesReader<T> = ComicReleaseFormValues Function(T value);
