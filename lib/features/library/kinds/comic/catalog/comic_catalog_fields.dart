import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';

/// Catalog fields consumed by the Comic kind.
final class ComicCatalogFields {
  const ComicCatalogFields._(this.summary, this.metadata);

  final CatalogCandidateSummary summary;
  final ComicCatalogItem? metadata;

  String get title => metadata?.title ?? summary.primaryLabel;
  String? get displayTitle => metadata?.displayTitle;
  String? get localizedTitle => metadata?.localizedTitle;
  String? get originalTitle => metadata?.originalTitle;
  String? get titleExtension => metadata?.titleExtension;
  List<String> get searchAliases => metadata?.searchAliases ?? const [];
  String? get sortKey => metadata?.sortTitle;
  String? get itemNumber => metadata?.issueNumber;
  String? get synopsis => metadata?.synopsis;
  String? get coverImageUrl => metadata?.coverImageUrl ?? summary.imageUrl;
  String? get thumbnailImageUrl =>
      metadata?.thumbnailImageUrl ?? summary.imageUrl;
  DateTime? get releaseDate =>
      metadata?.releaseDate ?? metadata?.releaseDateParts?.asDateTime;
  int? get releaseYear => releaseDate?.year ?? metadata?.releaseDateParts?.year;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension ComicCatalogCandidateFields on CatalogSearchCandidate {
  ComicCatalogFields get comicCatalogFields {
    try {
      return ComicCatalogFields._(
        summary,
        ComicCatalogItem.fromJson(
          kindCapability.mapTransport((item) => item).kindData,
        ),
      );
    } on StateError {
      return ComicCatalogFields._(summary, null);
    }
  }
}
