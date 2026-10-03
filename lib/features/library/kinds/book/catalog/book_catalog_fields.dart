import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

/// Catalog fields consumed by the Book kind.
final class BookCatalogFields {
  const BookCatalogFields._(this._candidate, this.metadata);

  final CatalogSearchCandidate _candidate;
  final BookCatalogMetadata? metadata;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => metadata?.title;
  String? get localizedTitle => metadata?.localizedTitle;
  String? get originalTitle => metadata?.originalTitle;
  String? get titleExtension => metadata?.titleExtension;
  List<String> get searchAliases => metadata?.searchAliases ?? const [];
  String? get sortKey => metadata?.sortTitle;
  String? get itemNumber => metadata?.itemNumber;
  String? get synopsis => metadata?.synopsis;
  String? get coverImageUrl =>
      metadata?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => metadata?.thumbnailImageUrl;
  String? get backCoverImageUrl => metadata?.backCoverImageUrl;
  List<String> get subjects => metadata?.subjects ?? const [];
  String? get physicalFormat => metadata?.physicalFormat;
  DateTime? get releaseDate =>
      metadata?.releaseDate ?? metadata?.releaseDateParts?.asDateTime;
  int? get releaseYear =>
      metadata?.releaseDateParts?.year ?? metadata?.releaseDate?.year;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension BookCatalogCandidateFields on CatalogSearchCandidate {
  BookCatalogFields get bookCatalogFields {
    try {
      final metadata = kindCapability.mapTransport(
        (item) => BookCatalogMetadata.fromJson(item.kindData),
      );
      return BookCatalogFields._(this, metadata);
    } on StateError {
      return BookCatalogFields._(this, null);
    }
  }
}
