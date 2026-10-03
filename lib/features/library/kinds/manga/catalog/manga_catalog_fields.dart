import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

/// Catalog fields consumed by the Manga kind.
final class MangaCatalogFields {
  const MangaCatalogFields._(this._candidate, this._item, this._metadata);

  final CatalogSearchCandidate _candidate;
  final CatalogItemDto? _item;
  final MangaMetadata? _metadata;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => _item?.displayTitle;
  String? get localizedTitle => _item?.localizedTitle;
  String? get originalTitle => _item?.originalTitle;
  String? get titleExtension => _item?.titleExtension;
  List<String> get searchAliases => _item?.searchAliases ?? const [];
  String? get sortKey => _metadata?.sortKey;
  String? get synopsis => null;
  String? get coverImageUrl =>
      _item?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _item?.thumbnailImageUrl;
  String? get coverImageData => _item?.coverImageData;
  DateTime? get releaseDate => _item?.releaseDate;
  int? get releaseYear => _item?.releaseYear;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension MangaCatalogCandidateFields on CatalogSearchCandidate {
  MangaCatalogFields get mangaCatalogFields {
    try {
      final item = kindCapability.mapTransport((item) => item);
      return MangaCatalogFields._(
        this,
        item,
        MangaMetadata.fromJson(item.kindData),
      );
    } on StateError {
      return MangaCatalogFields._(this, null, null);
    }
  }
}
