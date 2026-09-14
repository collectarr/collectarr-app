import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/media/boardgame_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/media/boardgame_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildBoardGameMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _BoardGameMediaSchemaEditDialog(request: request);

class _BoardGameMediaSchemaEditDialog extends StatefulWidget {
  const _BoardGameMediaSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_BoardGameMediaSchemaEditDialog> createState() =>
      _BoardGameMediaSchemaEditDialogState();
}

class _BoardGameMediaSchemaEditDialogState
    extends State<_BoardGameMediaSchemaEditDialog> {
  late final BoardGameMedia _media;
  late final BoardGameMediaEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _media = canonical is BoardGameMedia
        ? canonical
        : BoardGameMedia.fromJson(transport.payload);
    _draft = BoardGameMediaEditDraft.fromMedia(_media);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      EditSchemaRenderer<BoardGameMedia, BoardGameMediaEditDraft>(
        schema: boardGameMediaEditSchema,
        model: _media,
        draft: _draft,
        title: boardGameMediaEditSchema.title?.call(_media),
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
