import 'package:collectarr_app/core/models/partial_date.dart';

/// Editable catalog fields of one Game item, as on the reference Main and
/// Description tabs. Core fields without an editor are preserved on save.
final class GameCatalogFormValues {
  GameCatalogFormValues({
    this.title = '',
    this.sortTitle = '',
    this.platform = '',
    this.releaseDateParts,
    this.developers = const [],
    this.publishers = const [],
    this.series = '',
    this.barcode = '',
    this.format = '',
    this.editionTitle = '',
    this.region = '',
    this.audienceRating = '',
    this.genres = const [],
    this.description = '',
    this.coverImageUrl = '',
  });

  String title;
  String sortTitle;

  /// One platform per item, as in the reference.
  String platform;
  PartialDate? releaseDateParts;
  List<String> developers;
  List<String> publishers;
  String series;
  String barcode;
  String format;
  String editionTitle;
  String region;
  String audienceRating;
  List<String> genres;
  String description;

  /// Core front cover; cleared when the user removes it.
  String coverImageUrl;
}
