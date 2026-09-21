import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class GameWorkspaceDto implements LibraryWorkspaceDto {
  GameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.game,
    this.release,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final GameCatalogItem game;
  final GameRelease? release;
  final GameCatalogMetadata? metadata;

  GameRelease? get _effectiveRelease => release ?? game.primaryRelease;
  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  // Domain convenience getters
  String? get platform =>
      _effectiveRelease?.platform ??
      metadata?.platform ??
      (release == null ? game.platforms.firstOrNull : null);
  String? get franchise => metadata?.franchise;
  String? get edition => metadata?.edition;
  String? get ageRating => metadata?.ageRating;
  String? get developer => metadata?.developers.firstOrNull;
  String? get publisher =>
      _effectiveRelease?.publisher ??
      (release == null
          ? game.publisher ?? metadata?.publishers.firstOrNull ?? developer
          : null);
  String? get seriesTitle => null;
  String? get itemNumber => game.itemNumber;
  DateTime? get releaseDate =>
      _effectiveRelease?.releaseDate ??
      (release == null ? common.releaseDate : null);
  String? get country =>
      release == null ? game.country ?? metadata?.country : null;
  String? get language =>
      _effectiveRelease?.language ??
      (release == null
          ? game.language ?? metadata?.languages.firstOrNull
          : null);
  String? get identifierCode =>
      _effectiveRelease?.barcode ?? (release == null ? game.barcode : null);
  String? get barcode => identifierCode;
  String? get variant =>
      release?.title ?? (release == null ? game.variant : null);
  String? get referenceFormatLabel => _effectiveRelease?.format;
  String? get format => referenceFormatLabel;
  String? get region =>
      _effectiveRelease?.regionCode ??
      (release == null ? metadata?.releaseRegion : null);
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
