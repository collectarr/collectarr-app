import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';

/// Catalog fields consumed by the Game kind.
final class GameCatalogFields {
  const GameCatalogFields._(this.summary, this.metadata);

  final CatalogCandidateSummary summary;
  final GameCatalogMetadata? metadata;

  String get title => metadata?.title ?? summary.primaryLabel;
  String? get displayTitle => metadata?.displayTitle;
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
  DateTime? get releaseDate => metadata?.releaseDate;
  int? get releaseYear => releaseDate?.year;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension GameCatalogCandidateFields on CatalogSearchCandidate {
  GameCatalogFields get gameCatalogFields {
    try {
      final item = kindCapability.mapTransport((item) => item);
      return GameCatalogFields._(
        summary,
        GameCatalogMetadata.fromJson(item.kindData),
      );
    } on StateError {
      return GameCatalogFields._(summary, null);
    }
  }
}
