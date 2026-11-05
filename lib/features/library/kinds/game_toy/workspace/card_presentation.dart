import 'package:collectarr_app/features/library/workspace/tiles/card_templates.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'dto.dart';
import '../domain/game_toy_value_summary.dart';

LibraryCardPresentation buildGameToyCardPresentation(LibraryProjectionView item,
    {required bool coverFocused}) {
  final dto = item.dto as GameToyWorkspaceDto;
  final personal = dto.entry?.personal;
  return LibraryCardPresentation(
      coverBodyBuilder: buildStandardCoverContent,
      flowBodyBuilder: buildStandardFlowContent,
      flowFooterBuilder: (context, data) => buildStandardFlowFooter(
          context, data,
          title: item.dto.primaryLabel,
          meta: libraryFlowSubtitle(
              [dto.metadata.seriesTitle, dto.metadata.toyType]),
          numberLabel: null),
      shelfBodyBuilder: buildStandardShelfContent,
      horizontalBodyBuilder: buildStandardHorizontalCardBody,
      verticalBodyBuilder: buildStandardVerticalCardBody,
      verticalSubtitle: dto.metadata.toyType ??
          item.dto.secondaryLabel ??
          dto.metadata.seriesTitle,
      verticalSubtitleEmphasized: dto.metadata.toyType != null,
      verticalTrailing: personal == null ? null : gameToyValueSummary(personal),
      flowSubtitle: libraryFlowSubtitle([dto.metadata.toyType]),
      detailLine: dto.metadata.releaseDateParts?.isoString,
      seriesTitle: dto.metadata.seriesTitle,
      format: dto.metadata.toyType,
      valueLabel: personal == null ? null : gameToyValueSummary(personal),
      synopsis: dto.metadata.description,
      identifierCode: dto.metadata.barcode);
}
