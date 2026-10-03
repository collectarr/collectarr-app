import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

/// One concrete Board Game edition represented by a Core Catalog Item.
///
/// Player counts, contents, publisher, identifiers, and release details all
/// belong to this item. App-entry play sessions remain separate activity.
final class BoardGameCatalogItem {
  const BoardGameCatalogItem({
    required this.item,
    required this.metadata,
  });

  final CatalogItemDto item;
  final BoardGameMetadata metadata;

  String get id => item.id;
  String get title => item.title;
  String? get displayTitle => item.displayTitle;
  String? get originalTitle => metadata.originalTitle ?? item.originalTitle;
  String? get synopsis => metadata.synopsis;
  String? get itemNumber => metadata.itemNumber;
  String? get coverImageUrl => metadata.coverImageUrl ?? item.coverImageUrl;
  String? get thumbnailImageUrl =>
      metadata.thumbnailImageUrl ?? item.thumbnailImageUrl ?? coverImageUrl;
  DateTime? get releaseDate =>
      item.releaseDate ??
      metadata.releaseDate?.asDateTime ??
      metadata.releaseDateParts?.asDateTime;
  int? get releaseYear =>
      releaseDate?.year ?? metadata.yearPublished ?? item.releaseYear;
  String? get publisher =>
      metadata.publisher ?? metadata.publishers.firstOrNull ?? item.publisher;
  String? get barcode => metadata.barcode ?? item.barcode;
  String? get country => metadata.country;
  String? get language => metadata.language ?? metadata.languages.firstOrNull;
  String? get ageRating => metadata.ageRating;
  String? get audienceRating => metadata.audienceRating;
  String? get format => metadata.physicalFormatLabel ?? metadata.physicalFormat;
  String? get variant => metadata.variantName;
  List<String> get categories => metadata.categories;
  List<String> get mechanics => metadata.mechanics;
  List<String> get families => metadata.families;
  List<String> get themes => metadata.themes;
  List<String> get expansions => metadata.expansions;
  List<String> get designers => metadata.designers;
  List<String> get artists => metadata.artists;
  List<String> get publishers => metadata.publishers;
  List<String> get languages => metadata.languages;
  List<String> get contributors =>
      metadata.contributors.map((value) => value.name).toList(growable: false);

  CatalogItemDto toCatalogItemDto() => item.withKindData(metadata);
}
