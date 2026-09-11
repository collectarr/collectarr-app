import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

/// Opaque catalog snapshot crossing from a kind-owned import profile into the
/// catalog transport writer.
///
/// Collection orchestration can carry identity and kind without receiving the
/// canonical catalog DTO. The transport repository unwraps the DTO only when
/// it reaches the persistence boundary.
final class CatalogImportSnapshot {
  const CatalogImportSnapshot._(this._item);

  factory CatalogImportSnapshot.fromItem(CatalogItemDto item) {
    return CatalogImportSnapshot._(item);
  }

  /// Decodes a transport payload at the catalog serialization boundary.
  /// Library hosts should carry this opaque snapshot instead of rebuilding a
  /// Core DTO in application code.
  factory CatalogImportSnapshot.fromJson(Map<String, dynamic> json) {
    return CatalogImportSnapshot.fromItem(CatalogItemDto.fromJson(json));
  }

  factory CatalogImportSnapshot.synthetic({
    required String id,
    required CatalogMediaKind kind,
    required String title,
    DateTime? releaseDate,
  }) {
    return CatalogImportSnapshot.fromItem(
      CatalogItemDto.fromJson({
        'id': id,
        'kind': kind.apiValue,
        'title': title,
        'display_title': title,
        'localized_title': title,
        'original_title': title,
        'search_aliases': [title],
        if (releaseDate != null) 'release_date': releaseDate.toIso8601String(),
      }),
    );
  }

  final CatalogItemDto _item;

  String get id => _item.id;
  CatalogMediaKind get kind => _item.mediaKind;
  CatalogEntityRef get catalogRef => _item.catalogRef;
  String get title => _item.title;
  String? get coverImageData => _item.coverImageData;

  CatalogItemDto toTransportItem() => _item;
}
