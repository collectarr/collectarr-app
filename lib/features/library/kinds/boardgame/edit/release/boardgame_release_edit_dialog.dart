import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_schema.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildBoardGameReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _BoardGameReleaseSchemaEditDialog(request: request);

class _BoardGameReleaseSchemaEditDialog extends StatefulWidget {
  const _BoardGameReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_BoardGameReleaseSchemaEditDialog> createState() =>
      _BoardGameReleaseSchemaEditDialogState();
}

class _BoardGameReleaseSchemaEditDialogState
    extends State<_BoardGameReleaseSchemaEditDialog> {
  late final BoardGameMedia _media;
  late final BoardGameEdition _edition;
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
    _edition = _resolveEdition(
      _media,
      widget.request,
    );
    _values = boardGameCatalogFormValuesFromEdition(_edition);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<BoardGameEdition, BoardGameCatalogFormValues>(
        schema: boardGameEditionEditSchema,
        model: _edition,
        draft: _values,
        title:
            boardGameEditionEditSchema.title?.call(_edition) ?? 'Edit edition',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_boardgame_release',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _edition.toJson(),
          proposedFields: boardGameEditionFromCatalogFormValues(
            original: _edition,
            values: _values,
          ).toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updatedMedia = boardGameMediaWithEdition(
            _media,
            boardGameEditionFromCatalogFormValues(
              original: _edition,
              values: _values,
            ),
          );
          final candidate = widget.request.kindItem.kindCapability.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updatedMedia),
            ),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              kindItem: candidate,
              scope: LibraryEntityScope.release,
            ),
          );
        },
      );
}

BoardGameEdition _resolveEdition(
  BoardGameMedia media,
  LibraryEditDialogRequest request,
) {
  final requestedEditionId = switch (request.node) {
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
    _ => null,
  };
  if (requestedEditionId != null) {
    for (final edition in media.editions) {
      if (edition.id == requestedEditionId) return edition;
    }
    throw StateError(
      'Board game edition "$requestedEditionId" is not present in the canonical work graph',
    );
  }
  if (!request.editPrimaryRelease) {
    throw StateError(
      'Board game edition edit requires an explicit release selection or primary-release intent',
    );
  }
  if (media.editions.isNotEmpty) return media.editions.first;
  throw StateError('Board game edition edit requires a concrete release');
}
