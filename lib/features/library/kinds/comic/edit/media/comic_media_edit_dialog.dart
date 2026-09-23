import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
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
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
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
      LibraryEditSchemaDialog<ComicMedia, ComicMediaEditDraft>(
        schema: comicMediaEditSchema,
        model: _media,
        draft: _draft,
        title: comicMediaEditSchema.title?.call(_media) ?? 'Edit comic',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_comic_media',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _media.toJson(),
          proposedFields: _draft.controller
              .applySelectionEdits(
                LibraryEditSelection(
                  kindItem: widget.request.kindItem,
                ),
              )
              .kindItem
              .kindCapability
              .mapTransport(
                (transport) => transport.kindMetadata is ComicMedia
                    ? (transport.kindMetadata! as ComicMedia).toJson()
                    : _media.toJson(),
              ),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updated = _draft.controller.applySelectionEdits(
            LibraryEditSelection(
              kindItem: widget.request.kindItem,
            ),
          );
          Navigator.of(context).pop(updated);
        },
      );
}
