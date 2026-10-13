import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

/// Projects a concrete Board Game Catalog Item and its App-collection item state.
final class BoardGameWorkspaceProjector
    implements LibraryTargetWorkspaceProjector<BoardGameWorkspaceDto> {
  const BoardGameWorkspaceProjector();

  @override
  BoardGameWorkspaceDto project({
    required WorkspaceItem item,
    required PersonalOverlay personal,
  }) {
    final catalog = _catalogFor(item);
    return BoardGameWorkspaceDto(
      common: WorkspaceCommonProjection.fromKindPresentation(
        item,
        title: catalog.metadata.title,
        synopsis: catalog.metadata.synopsis,
        releaseDate: catalog.metadata.releaseDate?.asDateTime ??
            catalog.metadata.releaseDateParts?.asDateTime ??
            (catalog.metadata.yearPublished == null
                ? null
                : DateTime(catalog.metadata.yearPublished!)),
        coverImageUrl: catalog.metadata.coverImageUrl,
      ),
      personal: PersonalEntryProjection.fromShelf(item, personal),
      metadata: catalog.metadata,
    );
  }
}

BoardGameWorkspaceData _catalogFor(WorkspaceItem item) {
  final data = item.kindPresentationData;
  if (data case final BoardGameWorkspaceData catalog) return catalog;
  throw StateError(
    'Expected BoardGameWorkspaceData for board game workspace',
  );
}
