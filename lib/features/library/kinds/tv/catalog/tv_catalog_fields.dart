import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

/// Catalog fields consumed by the Tv kind.
final class TvCatalogFields {
  const TvCatalogFields._(this._candidate, this._common);

  final CatalogSearchCandidate _candidate;
  final CatalogCommonDto? _common;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => _common?.displayTitle;
  String? get localizedTitle => _common?.localizedTitle;
  String? get originalTitle => _common?.originalTitle;
  String? get titleExtension => _common?.titleExtension;
  List<String> get searchAliases => _common?.searchAliases ?? const [];
  String? get sortKey => _common?.sortKey;
  String? get synopsis => _common?.synopsis;
  String? get coverImageUrl => _common?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _common?.thumbnailImageUrl;
  String? get coverImageData => _common?.coverImageData;
  DateTime? get releaseDate => _common?.releaseDate;
  int? get releaseYear => _common?.releaseYear;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension TvCatalogCandidateFields on CatalogSearchCandidate {
  TvCatalogFields get tvCatalogFields {
    try {
      final common = kindCapability.mapTransport(
        (item) => item.common,
      );
      return TvCatalogFields._(this, common);
    } on StateError {
      return TvCatalogFields._(this, null);
    }
  }
}
