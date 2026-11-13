import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

/// Structural candidate data used by Board Game Add presentation.
final class BoardGameCatalogFields {
  const BoardGameCatalogFields._(this.summary, this.metadata);

  final CatalogCandidateSummary summary;
  final BoardGameMetadata? metadata;

  String get title => metadata?.title ?? summary.primaryLabel;
  String? get displayTitle => metadata?.titleExtension;
  String? get localizedTitle => metadata?.localizedTitle;
  String? get originalTitle => metadata?.originalTitle;
  String? get titleExtension => metadata?.titleExtension;
  List<String> get searchAliases => metadata?.searchAliases ?? const [];
  String? get sortKey => metadata?.sortKey;
  String? get itemNumber => metadata?.itemNumber;
  String? get synopsis => metadata?.synopsis;
  String? get coverImageUrl => metadata?.coverImageUrl ?? summary.imageUrl;
  String? get thumbnailImageUrl =>
      metadata?.thumbnailImageUrl ?? summary.imageUrl;
  DateTime? get releaseDate =>
      metadata?.releaseDate?.asDateTime ??
      metadata?.releaseDateParts?.asDateTime;
  int? get releaseYear => releaseDate?.year ?? metadata?.yearPublished;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension BoardGameCatalogCandidateFields on CatalogSearchCandidate {
  BoardGameCatalogFields get boardGameCatalogFields {
    try {
      final item = kindCapability.mapTransport((item) => item);
      return BoardGameCatalogFields._(
        summary,
        BoardGameMetadata.fromJson(item.kindData),
      );
    } on StateError {
      return BoardGameCatalogFields._(summary, null);
    }
  }
}
