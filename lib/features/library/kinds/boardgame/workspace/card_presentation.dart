import 'package:collectarr_app/features/library/workspace/tiles/card_templates.dart';
import 'package:collectarr_app/features/library/workspace/tiles/card_presentation.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'dto.dart';

LibraryCardPresentation buildBoardGameCardPresentation(
    LibraryProjectionView item,
    {required bool coverFocused}) {
  final dto = item.dto is BoardGameWorkspaceDto
      ? item.dto as BoardGameWorkspaceDto
      : null;
  return LibraryCardPresentation(
    coverBodyBuilder: buildStandardCoverContent,
    flowBodyBuilder: buildStandardFlowContent,
    flowFooterBuilder: (context, data) => buildStandardFlowFooter(context, data,
        title: item.dto.primaryLabel,
        meta: libraryFlowSubtitle([
          dto?.seriesTitle,
          dto?.publisher,
          libraryFlowDate(dto?.releaseDate),
          dto?.format
        ]),
        numberLabel: (dto?.itemNumber?.trim().isNotEmpty ?? false)
            ? '#${dto?.itemNumber}'
            : null),
    shelfBodyBuilder: buildStandardShelfContent,
    horizontalBodyBuilder: buildStandardHorizontalCardBody,
    verticalBodyBuilder: buildStandardVerticalCardBody,
    verticalSubtitle: dto?.format ??
        item.dto.secondaryLabel ??
        dto?.seriesTitle ??
        [dto?.publisher]
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .firstOrNull,
    verticalSubtitleEmphasized: dto?.format != null,
    verticalTrailing: dto?.releaseDate?.year.toString(),
    flowSubtitle: libraryFlowSubtitle([
      if (dto?.itemNumber?.trim().isNotEmpty ?? false) '#${dto?.itemNumber}',
      dto?.format,
      dto?.releaseDate?.year.toString()
    ]),
    itemNumber: dto?.itemNumber,
    variant: dto?.variant,
    releaseDate: dto?.releaseDate,
    format: dto?.format,
    synopsis: dto?.synopsis,
    seriesTitle: dto?.seriesTitle,
    identifierCode: dto?.identifierCode,
    currency: dto?.currency,
    contextFacts: [
      dto?.publisher,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
  );
}
