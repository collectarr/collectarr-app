import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';

/// Read-only Anime display fields projected from the selected kind document.
final class AnimeCatalogFields {
  const AnimeCatalogFields._(this._candidate, this._metadata);

  final CatalogSearchCandidate _candidate;
  final AnimeMetadata? _metadata;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => _metadata?.displayTitle;
  String? get localizedTitle => _metadata?.localizedTitle;
  String? get originalTitle => _metadata?.originalTitle;
  String? get titleExtension => _metadata?.titleExtension;
  List<String> get searchAliases => _metadata?.searchAliases ?? const [];
  String? get sortKey => _metadata?.sortKey;
  String? get synopsis => _metadata?.synopsis;
  String? get coverImageUrl =>
      _metadata?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _metadata?.thumbnailImageUrl;
  String? get coverImageData => _metadata?.coverImageData;
  DateTime? get releaseDate => _metadata?.releaseDate;
  int? get releaseYear =>
      _metadata?.releaseYear ?? _metadata?.releaseDateParts?.year;
  String? get editionTitle => _metadata?.editionTitle;
  String? get itemNumber => _metadata?.itemNumber;
  String? get variant => _metadata?.variant;
  String? get publisher => _metadata?.publisher;
  String? get barcode => _metadata?.barcode;
  String? get physicalFormat => _metadata?.physicalFormat;
  String? get physicalFormatLabel => _metadata?.physicalFormatLabel;
  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension AnimeCatalogCandidateFields on CatalogSearchCandidate {
  AnimeCatalogFields get animeCatalogFields {
    try {
      final metadata = kindCapability.mapTransport(
        (item) => AnimeMetadata.fromJson(item.kindData),
      );
      return AnimeCatalogFields._(this, metadata);
    } on StateError {
      return AnimeCatalogFields._(this, null);
    }
  }
}
