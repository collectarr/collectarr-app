import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

/// Catalog fields consumed by the Music kind.
final class MusicCatalogFields {
  const MusicCatalogFields._(this._candidate, this._item);

  final CatalogSearchCandidate _candidate;
  final CatalogItemDto? _item;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => _item?.displayTitle;
  String? get localizedTitle => _item?.localizedTitle;
  String? get originalTitle => _item?.originalTitle;
  String? get titleExtension => _item?.titleExtension;
  List<String> get searchAliases => _item?.searchAliases ?? const [];
  String? get sortKey => _item?.sortKey;
  String? get coverImageUrl =>
      _item?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _item?.thumbnailImageUrl;
  String? get coverImageData => _item?.coverImageData;
  DateTime? get releaseDate => _item?.releaseDate;
  int? get releaseYear => _item?.releaseYear;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension MusicCatalogCandidateFields on CatalogSearchCandidate {
  MusicCatalogFields get musicCatalogFields {
    try {
      final item = kindCapability.mapTransport((item) => item);
      return MusicCatalogFields._(this, item);
    } on StateError {
      return MusicCatalogFields._(this, null);
    }
  }
}
