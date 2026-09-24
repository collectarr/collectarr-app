import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
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
  late final BoardGameCatalogFormValues _values;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    final canonical = transport.kindMetadata;
    _media = canonical is BoardGameMedia
        ? canonical
        : BoardGameMedia.fromJson(transport.payload);
    _values = boardGameCatalogFormValuesFromMedia(_media);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<BoardGameMedia, BoardGameCatalogFormValues>(
        schema: boardGameMediaEditSchema,
        model: _media,
        draft: _values,
        title:
            boardGameMediaEditSchema.title?.call(_media) ?? 'Edit board game',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_boardgame_media',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _media.toJson(),
          proposedFields: boardGameMediaFromCatalogFormValues(
            original: _media,
            values: _values,
          ).toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updated = boardGameMediaFromCatalogFormValues(
            original: _media,
            values: _values,
          );
          final candidate = widget.request.kindItem.kindCapability.mapTransport(
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
