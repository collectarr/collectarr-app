import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';

/// Catalog fields consumed by the Movie kind.
final class MovieCatalogFields {
  const MovieCatalogFields._(this._candidate, this.metadata);

  final CatalogSearchCandidate _candidate;
  final MovieCatalogMetadata? metadata;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => metadata?.displayTitle;
  String? get localizedTitle => metadata?.localizedTitle;
  String? get originalTitle => metadata?.originalTitle;
  String? get titleExtension => metadata?.titleExtension;
  List<String> get searchAliases => metadata?.searchAliases ?? const [];
  String? get sortKey => metadata?.sortTitle;
  String? get itemNumber => metadata?.itemNumber;
  String? get synopsis => metadata?.synopsis ?? metadata?.description;
  String? get coverImageUrl =>
      metadata?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => metadata?.thumbnailImageUrl;
  String? get physicalFormat => metadata?.physicalFormat;
  DateTime? get releaseDate =>
      metadata?.releaseDate ?? metadata?.releaseDateParts?.asDateTime;
  int? get releaseYear => metadata?.releaseYear ?? releaseDate?.year;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension MovieCatalogCandidateFields on CatalogSearchCandidate {
  MovieCatalogFields get movieCatalogFields {
    try {
      final metadata = kindCapability.mapTransport(
        (item) => MovieCatalogMetadata.fromJson(item.kindData),
      );
      return MovieCatalogFields._(this, metadata);
    } on StateError {
      return MovieCatalogFields._(this, null);
    }
  }
}
