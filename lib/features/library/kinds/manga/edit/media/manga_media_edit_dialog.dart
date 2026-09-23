import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/media/manga_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/media/manga_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildMangaMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MangaMediaSchemaEditDialog(request: request);

class _MangaMediaSchemaEditDialog extends StatefulWidget {
  const _MangaMediaSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MangaMediaSchemaEditDialog> createState() =>
      _MangaMediaSchemaEditDialogState();
}

class _MangaMediaSchemaEditDialogState
    extends State<_MangaMediaSchemaEditDialog> {
  late final MangaMedia _media;
  late final MangaMediaEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport =
        widget.request.kindItem.mapTransport((transport) => transport);
    final canonical = transport.kindMetadata;
    _media = canonical is MangaMedia
        ? canonical
        : MangaMedia.fromJson(transport.payload);
    _draft = MangaMediaEditDraft.fromMedia(_media);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<MangaMedia, MangaMediaEditDraft>(
        schema: mangaMediaEditSchema,
        model: _media,
        draft: _draft,
        title: mangaMediaEditSchema.title?.call(_media) ?? 'Edit manga',
        icon: widget.request.type.identity.icon,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_manga_media',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _media.toJson(),
          proposedFields: _draft.toMedia().toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updated = _draft.toMedia();
          final candidate = widget.request.kindItem.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updated),
            ),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              kindItem: candidate,
            ),
          );
        },
      );
}
