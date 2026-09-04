import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildGameReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return _GameReleaseSchemaEditDialog(request: request);
}

class _GameReleaseSchemaEditDialog extends StatefulWidget {
  const _GameReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_GameReleaseSchemaEditDialog> createState() =>
      _GameReleaseSchemaEditDialogState();
}

class _GameReleaseSchemaEditDialogState
    extends State<_GameReleaseSchemaEditDialog> {
  late final LibraryEditDraft _editDraft;
  late final GameCatalogMetadata _metadata;
  late final GameRelease _release;
  late final GameReleaseEditDraft _releaseDraft;

  @override
  void initState() {
    super.initState();
    final metadata = widget.request.item.kindMetadata;
    if (metadata is! GameCatalogMetadata) {
      throw StateError('Expected GameCatalogMetadata for Game release editing');
    }
    _metadata = metadata;
    final game = GameCatalogMapper.mapMetadataItemToGame(widget.request.item);
    _release = _resolveRelease(
      game,
      widget.request.ownedItem?.editionId ??
          widget.request.trackingEntry?.editionId,
    );
    _releaseDraft = GameReleaseEditDraft.fromRelease(_release);
    _editDraft = LibraryEditDraft.fromRequest(widget.request);
  }

  @override
  void dispose() {
    _releaseDraft.dispose();
    _editDraft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditSchemaRenderer<GameRelease, GameReleaseEditDraft>(
      schema: gameReleaseEditSchema,
      model: _release,
      draft: _releaseDraft,
      title: gameReleaseEditSchema.title?.call(_release),
      onCancel: () => Navigator.of(context).pop(),
      onSave: (_) {
        final selection = _editDraft.toSelection(
          submitAction: LibraryEditSubmitAction.save,
        );
        final updatedRelease = _releaseDraft.toRelease();
        final updatedMetadata = _replaceRelease(_metadata, updatedRelease);
        Navigator.of(context).pop(
          selection.copyWith(
            item: selection.item.copyWith(kindMetadata: updatedMetadata),
            scope: LibraryEditScope.release,
          ),
        );
      },
    );
  }
}

GameRelease _resolveRelease(GameCatalogItem game, String? releaseId) {
  if (releaseId != null) {
    for (final release in game.releases) {
      if (release.id == releaseId) return release;
    }
  }
  if (game.releases.isNotEmpty) return game.releases.first;
  throw StateError('Game release editing requires a catalog release');
}

GameCatalogMetadata _replaceRelease(
  GameCatalogMetadata metadata,
  GameRelease release,
) {
  final existingEditions = metadata.rawPayload['editions'];
  final editions = existingEditions is List
      ? [
          for (final edition in existingEditions)
            if (edition is Map<Object?, Object?>)
              Map<String, dynamic>.from(edition),
        ]
      : <Map<String, dynamic>>[];
  final replacement = _releaseToEditionPayload(release);
  var replaced = false;
  for (var index = 0; index < editions.length; index++) {
    if (editions[index]['id']?.toString() == release.id) {
      editions[index] = replacement;
      replaced = true;
      break;
    }
  }
  if (!replaced) editions.add(replacement);

  return GameCatalogMetadata.fromJson({
    ...metadata.toJson(),
    'editions': editions,
  });
}

Map<String, dynamic> _releaseToEditionPayload(GameRelease release) => {
      'id': release.id,
      'title': release.title,
      if (release.platform != null) 'platform': release.platform,
      if (release.releaseDate != null)
        'release_date': release.releaseDate!.toIso8601String(),
      if (release.regionCode != null) 'region': release.regionCode,
      if (release.format != null) 'format': release.format,
      if (release.publisher != null) 'publisher': release.publisher,
      if (release.catalogNumber != null)
        'catalog_number': release.catalogNumber,
      if (release.releaseStatus != null)
        'release_status': release.releaseStatus,
      if (release.language != null) 'language': release.language,
      if (release.barcode != null) 'upc': release.barcode,
      if (release.coverImageUrl != null)
        'cover_image_url': release.coverImageUrl,
      ...release.rawPayload,
    };
