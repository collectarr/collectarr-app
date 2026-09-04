import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/media/boardgame_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildBoardGameMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return _BoardGameMediaSchemaEditDialog(request: request);
}

class _BoardGameMediaSchemaEditDialog extends StatefulWidget {
  const _BoardGameMediaSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_BoardGameMediaSchemaEditDialog> createState() =>
      _BoardGameMediaSchemaEditDialogState();
}

class _BoardGameMediaSchemaEditDialogState
    extends State<_BoardGameMediaSchemaEditDialog> {
  late final LibraryEditDraft _editDraft;
  late final BoardGameMetadata _metadata;
  late final BoardGameEditDraft _mediaDraft;

  @override
  void initState() {
    super.initState();
    final metadata = widget.request.item.kindMetadata;
    if (metadata is! BoardGameMetadata) {
      throw StateError(
        'Expected BoardGameMetadata for BoardGame media editing',
      );
    }
    _metadata = metadata;
    _editDraft = LibraryEditDraft.fromRequest(widget.request);
    final kindDraft = _editDraft.kindDetails;
    if (kindDraft is! BoardGameEditDraft) {
      throw StateError(
          'Expected BoardGameEditDraft for BoardGame media editing');
    }
    _mediaDraft = kindDraft;
  }

  @override
  void dispose() {
    _editDraft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditSchemaRenderer<BoardGameMetadata, BoardGameEditDraft>(
      schema: boardGameMediaEditSchema,
      model: _metadata,
      draft: _mediaDraft,
      title: boardGameMediaEditSchema.title?.call(_metadata),
      onCancel: () => Navigator.of(context).pop(),
      onSave: (_) {
        Navigator.of(context).pop(
          _editDraft.toSelection(submitAction: LibraryEditSubmitAction.save),
        );
      },
    );
  }
}
