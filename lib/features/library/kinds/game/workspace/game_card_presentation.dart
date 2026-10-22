import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

/// Reference card: title, release date, platform at the bottom and the
/// completeness and value pill.
LibraryCardPresentation buildGameCardPresentation(
  LibraryProjectionView item, {
  required bool coverFocused,
}) {
  final gameDto =
      item.dto is GameWorkspaceDto ? item.dto as GameWorkspaceDto : null;
  final entry =
      GameLibraryEntryProjection.fromDispatch(item.source.libraryEntryDispatch);
  final parts = gameDto?.metadata.releaseDateParts;
  final detailLine = switch (parts) {
    null => null,
    _ when parts.day != null && parts.asDateTime != null =>
      AppFormats.current.formatDate(parts.asDateTime!),
    _ => parts.isoString,
  };
  return LibraryCardPresentation(
    itemNumber: gameDto?.itemNumber,
    variant: gameDto?.variant,
    detailLine: detailLine,
    suggestionDetail: parts?.year?.toString(),
    format: gameDto?.platform,
    synopsis: gameDto?.synopsis,
    identifierCode: gameDto?.identifierCode,
    currency: gameDto?.currency,
    contextFacts: [
      gameDto?.platform,
      gameDto?.publisher,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
    valueLabel: entry == null ? null : gameValueSummary(entry.personal),
  );
}
