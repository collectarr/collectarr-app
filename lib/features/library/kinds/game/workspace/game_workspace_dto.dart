import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class GameWorkspaceDto extends WorkspaceDtoAdapter {
  GameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.game,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final GameCatalogItem game;
  final GameCatalogMetadata? metadata;

  // Domain convenience getters
  String? get franchise => metadata?.franchise;
  String? get edition => metadata?.edition;
  String? get ageRating => metadata?.ageRating;
  String? get developer => metadata?.developers.firstOrNull;
  String? get region => metadata?.releaseRegion;
  int? get loosePrice => metadata?.valuations?.loose?.amountCents;
  int? get cibPrice => metadata?.valuations?.cib?.amountCents;
  int? get newPrice => metadata?.valuations?.newSealed?.amountCents;
  int? get gradedPrice => metadata?.valuations?.graded?.amountCents;
  int? get boxOnlyPrice => metadata?.valuations?.boxOnly?.amountCents;
  int? get manualOnlyPrice => metadata?.valuations?.manualOnly?.amountCents;
}
