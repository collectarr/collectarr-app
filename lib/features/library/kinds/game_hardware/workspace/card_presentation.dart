import 'package:collectarr_app/features/library/workspace/tiles/card_templates.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'dto.dart';
import '../domain/game_hardware_value_summary.dart';

LibraryCardPresentation buildGameHardwareCardPresentation(
    LibraryProjectionView item,
    {required bool coverFocused}) {
  final dto = item.dto as GameHardwareWorkspaceDto;
  final personal = dto.entry?.personal;
  return LibraryCardPresentation(
      coverBodyBuilder: buildStandardCoverContent,
      flowBodyBuilder: buildStandardFlowContent,
      flowFooterBuilder: (context, data) => buildStandardFlowFooter(
          context, data,
          title: item.dto.primaryLabel,
          meta: libraryFlowSubtitle(
              [dto.metadata.seriesTitle, dto.metadata.platform]),
          numberLabel: null),
      shelfBodyBuilder: buildStandardShelfContent,
      horizontalBodyBuilder: buildStandardHorizontalCardBody,
      verticalBodyBuilder: buildStandardVerticalCardBody,
      verticalSubtitle: dto.metadata.platform ??
          item.dto.secondaryLabel ??
          dto.metadata.seriesTitle,
      verticalSubtitleEmphasized: dto.metadata.platform != null,
      verticalTrailing:
          personal == null ? null : gameHardwareValueSummary(personal),
      flowSubtitle: libraryFlowSubtitle([dto.metadata.platform]),
      detailLine: dto.metadata.releaseDateParts?.isoString,
      seriesTitle: dto.metadata.seriesTitle,
      format: dto.metadata.platform,
      valueLabel: personal == null ? null : gameHardwareValueSummary(personal),
      synopsis: dto.metadata.description,
      identifierCode: dto.metadata.barcode);
}
