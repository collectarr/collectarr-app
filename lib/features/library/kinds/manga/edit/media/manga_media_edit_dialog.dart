import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/media/manga_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildMangaMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return _MangaMediaSchemaEditDialog(request: request);
}

class _MangaMediaSchemaEditDialog extends StatefulWidget {
  const _MangaMediaSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MangaMediaSchemaEditDialog> createState() =>
      _MangaMediaSchemaEditDialogState();
}

class _MangaMediaSchemaEditDialogState
    extends State<_MangaMediaSchemaEditDialog> {
  late final LibraryEditDraft _editDraft;
  late final MangaMetadata _metadata;
  late final MangaEditDraft _mediaDraft;

  @override
  void initState() {
    super.initState();
    _metadata = widget.request.item.kindMetadata as MangaMetadata;
    _editDraft = LibraryEditDraft.fromRequest(widget.request);
    final kindDraft = _editDraft.kindDetails;
    if (kindDraft is! MangaEditDraft) {
      throw StateError('Expected MangaEditDraft for Manga media editing');
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
    return EditSchemaRenderer<MangaMetadata, MangaEditDraft>(
      schema: mangaMediaEditSchema,
      model: _metadata,
      draft: _mediaDraft,
      title: mangaMediaEditSchema.title?.call(_metadata),
      onCancel: () => Navigator.of(context).pop(),
      onSave: (_) {
        Navigator.of(context).pop(
          _editDraft.toSelection(submitAction: LibraryEditSubmitAction.save),
        );
      },
    );
  }
}
