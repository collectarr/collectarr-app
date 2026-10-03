import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

/// One concrete board game edition represented by a Core Catalog Item.
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
  String? get originalTitle => item.originalTitle;
  String? get synopsis => metadata.synopsis;
  String? get itemNumber => metadata.itemNumber;
  String? get coverImageUrl => item.coverImageUrl;
  String? get thumbnailImageUrl => item.thumbnailImageUrl ?? coverImageUrl;
  DateTime? get releaseDate =>
      item.releaseDate ?? _date(metadata.rawPayload['release_date']);
  int? get releaseYear => releaseDate?.year ?? metadata.yearPublished;
  String? get publisher =>
      metadata.publisher ?? metadata.publishers.firstOrNull ?? item.publisher;
  String? get barcode => metadata.barcode ?? item.barcode;
  String? get country => _text(metadata.rawPayload['country']);
  String? get language =>
      metadata.languages.firstOrNull ?? _text(metadata.rawPayload['language']);
  String? get ageRating => _text(metadata.rawPayload['age_rating']);
  String? get audienceRating => _text(metadata.rawPayload['audience_rating']);
  String? get format => metadata.physicalFormatLabel ?? metadata.physicalFormat;
  String? get variant => metadata.variant;
  List<String> get categories => metadata.categories;
  List<String> get mechanics => metadata.mechanics;
  List<String> get families => metadata.families;
  List<String> get themes => _strings(metadata.rawPayload['themes']);
  List<String> get expansions => metadata.expansions;
  List<String> get designers => metadata.designers;
  List<String> get artists => metadata.artists;
  List<String> get publishers => metadata.publishers;
  List<String> get languages => metadata.languages;
  List<String> get contributors =>
      _strings(metadata.rawPayload['contributors']);

  CatalogItemDto toCatalogItemDto() => item.withKindData(metadata);
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

List<String> _strings(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text,
      ]
    : const [];
