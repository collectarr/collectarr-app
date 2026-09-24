import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_schema.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildGameReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _GameReleaseSchemaEditDialog(request: request);

class _GameReleaseSchemaEditDialog extends StatefulWidget {
  const _GameReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_GameReleaseSchemaEditDialog> createState() =>
      _GameReleaseSchemaEditDialogState();
}

class _GameReleaseSchemaEditDialogState
    extends State<_GameReleaseSchemaEditDialog> {
  late final GameMedia _media;
  late final GameRelease _release;
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
    _release = _resolveRelease(
      _media,
      widget.request,
    );
    _values = gameCatalogFormValuesFromRelease(_release);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<GameRelease, GameCatalogFormValues>(
        schema: gameReleaseEditSchema,
        model: _release,
        draft: _values,
        title: gameReleaseEditSchema.title?.call(_release) ?? 'Edit release',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_game_release',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _release.toJson(),
          proposedFields: gameReleaseFromCatalogFormValues(
            original: _release,
            values: _values,
          ).toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updatedMedia = gameMediaWithRelease(
            _media,
            gameReleaseFromCatalogFormValues(
              original: _release,
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

GameRelease _resolveRelease(
  GameMedia media,
  LibraryEditDialogRequest request,
) {
  final requestedReleaseId = switch (request.node) {
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
    _ => null,
  };
  if (requestedReleaseId != null) {
    for (final release in media.releases) {
      if (release.id == requestedReleaseId) return release;
    }
    throw StateError(
      'Game release "$requestedReleaseId" is not present in the canonical work graph',
    );
  }
  if (!request.editPrimaryRelease) {
    throw StateError(
      'Game release edit requires an explicit release selection or primary-release intent',
    );
  }
  if (media.releases.isNotEmpty) return media.releases.first;
  throw StateError('Game release editing requires a catalog release');
}
