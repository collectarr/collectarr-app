import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/media/book_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildBookMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return _BookMediaSchemaEditDialog(request: request);
}

class _BookMediaSchemaEditDialog extends StatefulWidget {
  const _BookMediaSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_BookMediaSchemaEditDialog> createState() =>
      _BookMediaSchemaEditDialogState();
}

class _BookMediaSchemaEditDialogState
    extends State<_BookMediaSchemaEditDialog> {
  late final LibraryEditDraft _editDraft;
  late final BookCatalogMetadata _metadata;
  late final BookEditDraft _bookDraft;

  @override
  void initState() {
    super.initState();
    _metadata = widget.request.item.kindMetadata as BookCatalogMetadata;
    _editDraft = LibraryEditDraft.fromRequest(widget.request);
    final kindDraft = _editDraft.kindDetails;
    if (kindDraft is! BookEditDraft) {
      throw StateError('Expected BookEditDraft for Book media editing');
    }
    _bookDraft = kindDraft;
  }

  @override
  void dispose() {
    _editDraft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditSchemaRenderer<BookCatalogMetadata, BookEditDraft>(
      schema: bookMediaEditSchema,
      model: _metadata,
      draft: _bookDraft,
      title: bookMediaEditSchema.title?.call(_metadata),
      onCancel: () => Navigator.of(context).pop(),
      onSave: (_) {
        Navigator.of(context).pop(
          _editDraft.toSelection(submitAction: LibraryEditSubmitAction.save),
        );
      },
    );
  }
}
