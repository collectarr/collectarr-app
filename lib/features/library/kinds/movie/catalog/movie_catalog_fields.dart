import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';

/// Catalog fields consumed by the Movie kind.
final class MovieCatalogFields {
  const MovieCatalogFields._(this._candidate, this._metadata);

  final CatalogSearchCandidate _candidate;
  final MovieCatalogMetadata? _metadata;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => _metadata?.displayTitle;
  String? get localizedTitle => _metadata?.localizedTitle;
  String? get originalTitle => _metadata?.originalTitle;
  String? get titleExtension => _metadata?.titleExtension;
  List<String> get searchAliases => _metadata?.searchAliases ?? const [];
  String? get sortKey => _metadata?.sortTitle;
  String? get synopsis => _metadata?.synopsis ?? _metadata?.description;
  String? get coverImageUrl =>
      _metadata?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _metadata?.thumbnailImageUrl;
  String? get physicalFormat => _metadata?.physicalFormat;
  DateTime? get releaseDate =>
      _metadata?.releaseDate ?? _metadata?.releaseDateParts?.asDateTime;
  int? get releaseYear => _metadata?.releaseYear;

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
