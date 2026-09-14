import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/media/book_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/media/book_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildBookMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _BookMediaSchemaEditDialog(request: request);

class _BookMediaSchemaEditDialog extends StatefulWidget {
  const _BookMediaSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_BookMediaSchemaEditDialog> createState() =>
      _BookMediaSchemaEditDialogState();
}

class _BookMediaSchemaEditDialogState
    extends State<_BookMediaSchemaEditDialog> {
  late final BookMedia _media;
  late final BookMediaEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _media = canonical is BookMedia
        ? canonical
        : BookMedia.fromJson(transport.payload);
    _draft = BookMediaEditDraft.fromMedia(_media);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      EditSchemaRenderer<BookMedia, BookMediaEditDraft>(
        schema: bookMediaEditSchema,
        model: _media,
        draft: _draft,
        title: bookMediaEditSchema.title?.call(_media),
        onCancel: () => Navigator.of(context).pop(),
        onSave: (_) {
          final updated = _draft.toMedia();
          final candidate = widget.request.kindItem.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updated),
            ),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              item: candidate.editMetadata,
              kindItem: candidate,
              personal: null,
            ),
          );
        },
      );
}
