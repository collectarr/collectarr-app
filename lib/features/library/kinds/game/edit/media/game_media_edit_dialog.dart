import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';
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
  late final GameCatalogFormValues _values;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    final canonical = transport.kindMetadata;
    _media = canonical is GameMedia
        ? canonical
        : GameMedia.fromJson(transport.payload);
    _values = gameCatalogFormValuesFromMedia(_media);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<GameMedia, GameCatalogFormValues>(
        schema: gameMediaEditSchema,
        model: _media,
        draft: _values,
        title: gameMediaEditSchema.title?.call(_media) ?? 'Edit game',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_game_media',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _media.toJson(),
          proposedFields: gameMediaFromCatalogFormValues(
            original: _media,
            values: _values,
          ).toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updated = gameMediaFromCatalogFormValues(
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
