import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceDto extends WorkspaceDtoAdapter {
  BoardGameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.boardgame,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final BoardGameCatalogItem boardgame;
  final BoardGameMetadata? metadata;

  String? get publisher => boardgame.publisher ?? metadata?.publisher;
  @override
  String? get seriesTitle =>
      metadata?.seriesTitle ?? metadata?.series?.seriesTitle;
  @override
  String? get itemNumber => metadata?.itemNumber;
  @override
  DateTime? get releaseDate => boardgame.releaseDate ?? common.releaseDate;
  @override
  String? get country => boardgame.country;
  @override
  String? get language => boardgame.language;
  @override
  String? get identifierCode => boardgame.barcode;
  String? get barcode => identifierCode;
  @override
  String? get variant => metadata?.variant;
  @override
  String? get referenceFormatLabel => boardgame.format;
  @override
  String? get format => referenceFormatLabel;

  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
      ];
}
