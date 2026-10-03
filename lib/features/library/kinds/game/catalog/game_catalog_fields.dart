import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';

/// Catalog fields consumed by the Game kind.
final class GameCatalogFields {
  const GameCatalogFields._(this._candidate, this._item, this._metadata);

  final CatalogSearchCandidate _candidate;
  final CatalogItemDto? _item;
  final GameCatalogMetadata? _metadata;

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

extension GameCatalogCandidateFields on CatalogSearchCandidate {
  GameCatalogFields get gameCatalogFields {
    try {
      final item = kindCapability.mapTransport((item) => item);
      return GameCatalogFields._(
        this,
        item,
        GameCatalogMetadata.fromJson(item.kindData),
      );
    } on StateError {
      return GameCatalogFields._(this, null, null);
    }
  }
}
