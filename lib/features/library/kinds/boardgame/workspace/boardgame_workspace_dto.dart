import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceDto implements LibraryWorkspaceDto {
  BoardGameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.boardgame,
    this.release,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final BoardGameCatalogItem boardgame;
  final BoardGameEdition? release;
  final BoardGameMetadata? metadata;

  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;
  @override
  String get primaryLabel => title;
  @override
  String? get imageUrl => coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  String? get publisher =>
      release?.publisher ??
      (release == null ? boardgame.publisher ?? metadata?.publisher : null);
  String? get seriesTitle =>
      metadata?.seriesTitle ?? metadata?.series?.seriesTitle;
  String? get itemNumber => metadata?.itemNumber;
  DateTime? get releaseDate =>
      release?.releaseDate ?? (release == null ? common.releaseDate : null);
  String? get country =>
      release?.country ?? (release == null ? boardgame.country : null);
  String? get language =>
      release?.language ?? (release == null ? boardgame.language : null);
  String? get identifierCode =>
      release?.barcode ?? (release == null ? boardgame.barcode : null);
  String? get barcode => identifierCode;
  String? get variant => metadata?.variant;
  String? get referenceFormatLabel => release?.format;
  String? get format => referenceFormatLabel;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
      ];
}
