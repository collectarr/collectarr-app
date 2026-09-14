import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/media/comic_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/media/comic_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildComicMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _ComicMediaEditDialog(request: request);

class _ComicMediaEditDialog extends StatefulWidget {
  const _ComicMediaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_ComicMediaEditDialog> createState() => _ComicMediaEditDialogState();
}

class _ComicMediaEditDialogState extends State<_ComicMediaEditDialog> {
  late final ComicMedia _media;
  late final ComicMediaEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _media = canonical is ComicMedia
        ? canonical
        : ComicMedia.fromJson(transport.payload);
    _draft = ComicMediaEditDraft.fromMedia(_media);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      EditSchemaRenderer<ComicMedia, ComicMediaEditDraft>(
        schema: comicMediaEditSchema,
        model: _media,
        draft: _draft,
        title: comicMediaEditSchema.title?.call(_media),
        onCancel: () => Navigator.of(context).pop(),
        onSave: (_) {
          final updated = _draft.controller.applySelectionEdits(
            LibraryEditSelection(
              item: widget.request.kindItem.editMetadata,
              kindItem: widget.request.kindItem,
              personal: null,
            ),
          );
          Navigator.of(context).pop(updated);
        },
      );
}
