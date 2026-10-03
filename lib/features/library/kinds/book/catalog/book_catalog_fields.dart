import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

/// Catalog fields consumed by the Book kind.
final class BookCatalogFields {
  const BookCatalogFields._(this._candidate, this._metadata);

  final CatalogSearchCandidate _candidate;
  final BookCatalogMetadata? _metadata;

  String get title => _candidate.summary.primaryLabel;
  String? get displayTitle => _metadata?.title;
  String? get localizedTitle => _metadata?.localizedTitle;
  String? get originalTitle => _metadata?.originalTitle;
  String? get titleExtension => _metadata?.titleExtension;
  List<String> get searchAliases => _metadata?.searchAliases ?? const [];
  String? get sortKey => _metadata?.sortTitle;
  String? get itemNumber => _metadata?.itemNumber;
  String? get synopsis => _metadata?.synopsis;
  String? get coverImageUrl =>
      _metadata?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _metadata?.thumbnailImageUrl;
  String? get backCoverImageUrl => _metadata?.backCoverImageUrl;
  List<String> get subjects => _metadata?.subjects ?? const [];
  String? get physicalFormat => _metadata?.physicalFormat;
  DateTime? get releaseDate =>
      _metadata?.releaseDate ?? _metadata?.releaseDateParts?.asDateTime;
  int? get releaseYear =>
      _metadata?.releaseDateParts?.year ?? _metadata?.releaseDate?.year;

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
