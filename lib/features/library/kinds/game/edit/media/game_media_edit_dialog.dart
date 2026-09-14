import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/media/game_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/media/game_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildGameMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _GameMediaSchemaEditDialog(request: request);

class _GameMediaSchemaEditDialog extends StatefulWidget {
  const _GameMediaSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_GameMediaSchemaEditDialog> createState() =>
      _GameMediaSchemaEditDialogState();
}

class _GameMediaSchemaEditDialogState
    extends State<_GameMediaSchemaEditDialog> {
  late final GameMedia _media;
  late final GameMediaEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _media = canonical is GameMedia
        ? canonical
        : GameMedia.fromJson(transport.payload);
    _draft = GameMediaEditDraft.fromMedia(_media);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<GameMedia, GameMediaEditDraft>(
        schema: gameMediaEditSchema,
        model: _media,
        draft: _draft,
        title: gameMediaEditSchema.title?.call(_media) ?? 'Edit game',
        icon: widget.request.type.identity.icon,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_game_media',
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
              item: candidate.editMetadata,
              kindItem: candidate,
              personal: null,
            ),
          );
        },
      );
}
