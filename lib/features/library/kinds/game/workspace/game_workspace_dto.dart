import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class GameWorkspaceDto implements LibraryWorkspaceDto {
  GameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final GameCatalogMetadata metadata;

  String get title => common.title;
  String? get coverImageUrl => common.coverImageUrl;
  @override
  String get primaryLabel => title;
  @override
  String? get imageUrl => coverImageUrl;
  @override
  String? get secondaryLabel => null;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  // Domain convenience getters
  String? get platform => metadata.platforms.firstOrNull;
  String? get franchise => metadata.franchise;
  String? get edition => metadata.editionTitle ?? metadata.variantName;
  String? get ageRating => metadata.ageRating;
  String? get developer => metadata.developers.firstOrNull;
  String? get publisher => metadata.publisher ?? developer;
  String? get seriesTitle => null;
  String? get itemNumber => metadata.itemNumber;
  DateTime? get releaseDate => metadata.releaseDate ?? common.releaseDate;
  String? get country => metadata.country;
  String? get language => metadata.language ?? metadata.languages.firstOrNull;
  String? get identifierCode => metadata.barcode;
  String? get barcode => identifierCode;
  String? get variant => metadata.variantName ?? metadata.editionTitle;
  String? get referenceFormatLabel =>
      metadata.physicalFormatLabel ?? metadata.physicalFormat;
  String? get format => referenceFormatLabel;
  String? get region => metadata.releaseRegion ?? metadata.country;
  int? get loosePrice => metadata.valuations?.loose?.amountCents;
  int? get cibPrice => metadata.valuations?.cib?.amountCents;
  int? get newPrice => metadata.valuations?.newSealed?.amountCents;
  int? get gradedPrice => metadata.valuations?.graded?.amountCents;
  int? get boxOnlyPrice => metadata.valuations?.boxOnly?.amountCents;
  int? get manualOnlyPrice => metadata.valuations?.manualOnly?.amountCents;
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
