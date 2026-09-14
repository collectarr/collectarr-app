import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceDto implements LibraryWorkspaceDto {
  BoardGameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.boardgame,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final BoardGameCatalogItem boardgame;
  final BoardGameMetadata? metadata;
  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  String? get publisher => boardgame.publisher ?? metadata?.publisher;
  String? get seriesTitle =>
      metadata?.seriesTitle ?? metadata?.series?.seriesTitle;
  String? get itemNumber => metadata?.itemNumber;
  DateTime? get releaseDate => boardgame.releaseDate ?? common.releaseDate;
  String? get country => boardgame.country;
  String? get language => boardgame.language;
  String? get identifierCode => boardgame.barcode;
  String? get barcode => identifierCode;
  String? get variant => metadata?.variant;
  String? get referenceFormatLabel => boardgame.format;
  String? get format => referenceFormatLabel;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
      ];
}
