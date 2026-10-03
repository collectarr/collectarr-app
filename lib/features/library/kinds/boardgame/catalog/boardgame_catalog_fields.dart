import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

/// Catalog fields consumed by the BoardGame kind.
final class BoardGameCatalogFields {
  const BoardGameCatalogFields._(this._candidate, this._item, this._metadata);

  final CatalogSearchCandidate _candidate;
  final CatalogItemDto? _item;
  final BoardGameMetadata? _metadata;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => _item?.displayTitle;
  String? get localizedTitle => _item?.localizedTitle;
  String? get originalTitle => _item?.originalTitle;
  String? get titleExtension => _item?.titleExtension;
  List<String> get searchAliases => _item?.searchAliases ?? const [];
  String? get sortKey => _metadata?.sortKey;
  String? get itemNumber => _metadata?.itemNumber;
  String? get synopsis => _metadata?.synopsis;
  String? get coverImageUrl =>
      _item?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _item?.thumbnailImageUrl;
  String? get coverImageData => _item?.coverImageData;
  DateTime? get releaseDate => _item?.releaseDate;
  int? get releaseYear => _item?.releaseYear;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension BoardGameCatalogCandidateFields on CatalogSearchCandidate {
  BoardGameCatalogFields get boardGameCatalogFields {
    try {
      final item = kindCapability.mapTransport((item) => item);
      return BoardGameCatalogFields._(
        this,
        item,
        BoardGameMetadata.fromJson(item.kindData),
      );
    } on StateError {
      return BoardGameCatalogFields._(this, null, null);
    }
  }
}
