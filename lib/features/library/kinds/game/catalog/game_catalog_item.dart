import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';

/// One concrete video game edition represented by a Core Catalog Item.
///
/// Platform, region, edition, publisher, identifiers, and release date belong
/// to this item. It has no nested Work or Release records.
final class GameCatalogItem {
  const GameCatalogItem({
    required this.item,
    required this.metadata,
  });

  final CatalogItemDto item;
  final GameCatalogMetadata metadata;

  String get id => item.id;
  String get title => item.title;
  String? get displayTitle => item.displayTitle;
  String? get originalTitle => item.originalTitle;
  String? get synopsis => metadata.synopsis;
  String? get itemNumber => metadata.itemNumber;
  String? get coverImageUrl => item.coverImageUrl;
  String? get thumbnailImageUrl => item.thumbnailImageUrl ?? coverImageUrl;
  String? get publisher => metadata.publisher ?? item.publisher;
  DateTime? get releaseDate => metadata.releaseDate ?? item.releaseDate;
  int? get releaseYear => releaseDate?.year ?? item.releaseYear;
  String? get barcode => metadata.barcode ?? item.barcode;
  String? get edition => metadata.editionTitle ?? item.editionTitle;
  String? get variant => metadata.variantName ?? edition;
  String? get country => metadata.country;
  String? get language => metadata.languages.firstOrNull;
  String? get physicalFormat =>
      metadata.physicalFormatLabel ??
      metadata.physicalFormat ??
      item.physicalFormatLabel;
  List<String> get genres => metadata.genres;
  List<String> get platforms => metadata.platforms;

  CatalogItemDto toCatalogItemDto() => item.withKindData(metadata);
}
