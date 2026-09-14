import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class GameWorkspaceDto implements LibraryWorkspaceDto {
  GameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.game,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final GameCatalogItem game;
  final GameCatalogMetadata? metadata;
  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  // Domain convenience getters
  String? get platform => metadata?.platform ?? game.platforms.firstOrNull;
  String? get franchise => metadata?.franchise;
  String? get edition => metadata?.edition;
  String? get ageRating => metadata?.ageRating;
  String? get developer => metadata?.developers.firstOrNull;
  String? get publisher =>
      game.publisher ?? metadata?.publishers.firstOrNull ?? developer;
  String? get seriesTitle => null;
  String? get itemNumber => game.itemNumber;
  DateTime? get releaseDate => game.releaseDate ?? common.releaseDate;
  String? get country => game.country ?? metadata?.country;
  String? get language => game.language ?? metadata?.languages.firstOrNull;
  String? get identifierCode => game.barcode;
  String? get barcode => identifierCode;
  String? get variant => game.variant;
  String? get referenceFormatLabel => game.primaryRelease?.format;
  String? get format => referenceFormatLabel;
  String? get region => metadata?.releaseRegion;
  int? get loosePrice => metadata?.valuations?.loose?.amountCents;
  int? get cibPrice => metadata?.valuations?.cib?.amountCents;
  int? get newPrice => metadata?.valuations?.newSealed?.amountCents;
  int? get gradedPrice => metadata?.valuations?.graded?.amountCents;
  int? get boxOnlyPrice => metadata?.valuations?.boxOnly?.amountCents;
  int? get manualOnlyPrice => metadata?.valuations?.manualOnly?.amountCents;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (platform != null) platform!,
        if (franchise != null) franchise!,
        if (developer != null) developer!,
        if (region != null) region!,
      ];
}
