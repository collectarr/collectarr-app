import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

/// Catalog fields consumed by the Manga kind.
final class MangaCatalogFields {
  const MangaCatalogFields._(this._candidate, this._metadata);

  final CatalogSearchCandidate _candidate;
  final MangaMetadata? _metadata;

  String get title => _metadata?.title ?? _candidate.summary.primaryLabel;
  String? get localizedTitle => _metadata?.localizedTitle;
  String? get originalTitle => _metadata?.originalTitle;
  String? get titleExtension => _metadata?.titleExtension;
  List<String> get searchAliases => _metadata?.searchAliases ?? const [];
  String? get sortKey => _metadata?.sortKey;
  String? get itemNumber =>
      _metadata?.itemNumber ?? _metadata?.volumeNumber?.toString();
  String? get synopsis => _metadata?.synopsis ?? _metadata?.description;
  String? get coverImageUrl =>
      _metadata?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _metadata?.thumbnailImageUrl;
  String? get coverImageData => null;
  DateTime? get releaseDate => _metadata?.releaseDate?.asDateTime;
  int? get releaseYear => _metadata?.releaseDate?.year;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension MangaCatalogCandidateFields on CatalogSearchCandidate {
  MangaCatalogFields get mangaCatalogFields {
    try {
      final metadata = kindCapability.mapTransport(
        (transport) => MangaMetadata.fromJson(transport.kindData),
      );
      return MangaCatalogFields._(this, metadata);
    } on StateError {
      return MangaCatalogFields._(this, null);
    }
  }
}
