import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

/// Catalog fields consumed by the Manga kind.
final class MangaCatalogFields {
  const MangaCatalogFields._(this._candidate, this.metadata);

  final CatalogSearchCandidate _candidate;
  final MangaMetadata? metadata;

  String get title => metadata?.title ?? _candidate.summary.primaryLabel;
  String? get localizedTitle => metadata?.localizedTitle;
  String? get originalTitle => metadata?.originalTitle;
  String? get titleExtension => metadata?.titleExtension;
  List<String> get searchAliases => metadata?.searchAliases ?? const [];
  String? get sortKey => metadata?.sortKey;
  String? get itemNumber =>
      metadata?.itemNumber ?? metadata?.volumeNumber?.toString();
  String? get synopsis => metadata?.synopsis ?? metadata?.description;
  String? get coverImageUrl =>
      metadata?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => metadata?.thumbnailImageUrl;
  String? get coverImageData => null;
  DateTime? get releaseDate => metadata?.releaseDate?.asDateTime;
  int? get releaseYear => metadata?.releaseDate?.year;

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
