import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/media/game_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildGameMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return _GameMediaSchemaEditDialog(request: request);
}

class _GameMediaSchemaEditDialog extends StatefulWidget {
  const _GameMediaSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_GameMediaSchemaEditDialog> createState() =>
      _GameMediaSchemaEditDialogState();
}

class _GameMediaSchemaEditDialogState
    extends State<_GameMediaSchemaEditDialog> {
  late final LibraryEditDraft _editDraft;
  late final GameCatalogMetadata _metadata;
  late final GameEditDraft _gameDraft;

  @override
  void initState() {
    super.initState();
    final metadata = widget.request.item.kindMetadata;
    if (metadata is! GameCatalogMetadata) {
      throw StateError('Expected GameCatalogMetadata for Game media editing');
    }
    _metadata = metadata;
    _editDraft = LibraryEditDraft.fromRequest(widget.request);
    final kindDraft = _editDraft.kindDetails;
    if (kindDraft is! GameEditDraft) {
      throw StateError('Expected GameEditDraft for Game media editing');
    }
    _gameDraft = kindDraft;
  }

  @override
  void dispose() {
    _editDraft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditSchemaRenderer<GameCatalogMetadata, GameEditDraft>(
      schema: gameMediaEditSchema,
      model: _metadata,
      draft: _gameDraft,
      title: gameMediaEditSchema.title?.call(_metadata),
      onCancel: () => Navigator.of(context).pop(),
      onSave: (_) {
        Navigator.of(context).pop(
          _editDraft.toSelection(submitAction: LibraryEditSubmitAction.save),
        );
      },
    );
  }
}
