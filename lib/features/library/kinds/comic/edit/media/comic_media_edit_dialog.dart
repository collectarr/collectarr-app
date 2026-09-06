import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/media/comic_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/media/comic_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildComicMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return _ComicMediaSchemaEditDialog(request: request);
}

class _ComicMediaSchemaEditDialog extends StatefulWidget {
  const _ComicMediaSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_ComicMediaSchemaEditDialog> createState() =>
      _ComicMediaSchemaEditDialogState();
}

class _ComicMediaSchemaEditDialogState
    extends State<_ComicMediaSchemaEditDialog> {
  late final LibraryEditDraft _editDraft;
  late final ComicMedia _metadata;
  late final ComicMediaEditDraft _mediaDraft;

  @override
  void initState() {
    super.initState();
    _metadata = widget.request.item.kindMetadata as ComicMedia;
    _editDraft = LibraryEditDraft.fromRequest(widget.request);
    final kindDraft = _editDraft.kindDetails;
    if (kindDraft is! ComicEditDraft) {
      throw StateError('Expected ComicEditDraft for Comic media editing');
    }
    _mediaDraft = ComicMediaEditDraft(kindDraft.comicEdit);
  }

  @override
  void dispose() {
    _editDraft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditSchemaRenderer<ComicMedia, ComicMediaEditDraft>(
      schema: comicMediaEditSchema,
      model: _metadata,
      draft: _mediaDraft,
      onCancel: () => Navigator.of(context).pop(),
      onSave: (_) {
        Navigator.of(context).pop(
          _editDraft.toSelection(submitAction: LibraryEditSubmitAction.save),
        );
      },
    );
  }
}
