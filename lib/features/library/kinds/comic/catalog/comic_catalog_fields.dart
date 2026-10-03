import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';

/// Catalog fields consumed by the Comic kind.
final class ComicCatalogFields {
  const ComicCatalogFields._(this._candidate, this._item, this._metadata);

  final CatalogSearchCandidate _candidate;
  final CatalogItemDto? _item;
  final ComicCatalogItem? _metadata;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => _item?.displayTitle;
  String? get localizedTitle => _item?.localizedTitle;
  String? get originalTitle => _item?.originalTitle;
  String? get titleExtension => _item?.titleExtension;
  List<String> get searchAliases => _item?.searchAliases ?? const [];
  String? get sortKey => _metadata?.sortTitle;
  String? get synopsis => _metadata?.synopsis;
  String? get coverImageUrl =>
      _item?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _item?.thumbnailImageUrl;
  String? get coverImageData => _item?.coverImageData;
  DateTime? get releaseDate => _item?.releaseDate;
  int? get releaseYear => _item?.releaseYear;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension ComicCatalogCandidateFields on CatalogSearchCandidate {
  ComicCatalogFields get comicCatalogFields {
    try {
      final item = kindCapability.mapTransport((item) => item);
      return ComicCatalogFields._(
        this,
        item,
        ComicCatalogItem.fromJson(item.kindData),
      );
    } on StateError {
      return ComicCatalogFields._(this, null, null);
    }
  }
}
