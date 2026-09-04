import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildBoardGameReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return _BoardGameReleaseSchemaEditDialog(request: request);
}

class _BoardGameReleaseSchemaEditDialog extends StatefulWidget {
  const _BoardGameReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_BoardGameReleaseSchemaEditDialog> createState() =>
      _BoardGameReleaseSchemaEditDialogState();
}

class _BoardGameReleaseSchemaEditDialogState
    extends State<_BoardGameReleaseSchemaEditDialog> {
  late final LibraryEditDraft _editDraft;
  late final BoardGameMetadata _metadata;
  late final BoardGameRelease _release;
  late final BoardGameEditionEditDraft _releaseDraft;

  @override
  void initState() {
    super.initState();
    final metadata = widget.request.item.kindMetadata;
    if (metadata is! BoardGameMetadata) {
      throw StateError(
        'Expected BoardGameMetadata for BoardGame release editing',
      );
    }
    _metadata = metadata;
    final boardGame =
        BoardGameCatalogMapper.mapMetadataItemToBoardGame(widget.request.item);
    _release = _resolveRelease(
      boardGame,
      widget.request.ownedItem?.editionId ??
          widget.request.trackingEntry?.editionId,
    );
    _releaseDraft = BoardGameEditionEditDraft.fromRelease(_release);
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
    return EditSchemaRenderer<BoardGameRelease, BoardGameEditionEditDraft>(
      schema: boardGameEditionEditSchema,
      model: _release,
      draft: _releaseDraft,
      title: boardGameEditionEditSchema.title?.call(_release),
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

BoardGameRelease _resolveRelease(
  BoardGameCatalogItem boardGame,
  String? releaseId,
) {
  if (releaseId != null) {
    for (final release in boardGame.releases) {
      if (release.id == releaseId) return release;
    }
  }
  if (boardGame.releases.isNotEmpty) return boardGame.releases.first;
  return BoardGameRelease(
    id: '${boardGame.id}-edition',
    title: boardGame.title,
    workId: boardGame.id,
    ageRating: boardGame.ageRating,
    barcode: boardGame.barcode,
    country: boardGame.country,
    coverImageUrl: boardGame.coverImageUrl,
    format: boardGame.format,
    language: boardGame.language,
    publisher: boardGame.publisher,
    releaseDate: boardGame.releaseDate,
  );
}

BoardGameMetadata _replaceRelease(
  BoardGameMetadata metadata,
  BoardGameRelease release,
) {
  final rawEditions = metadata.rawPayload['editions'];
  final editions = rawEditions is List
      ? [
          for (final edition in rawEditions)
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

  return BoardGameMetadata.fromJson({
    ...metadata.toJson(),
    'editions': editions,
  });
}

Map<String, dynamic> _releaseToEditionPayload(BoardGameRelease release) {
  final payload = Map<String, dynamic>.from(release.rawPayload)
    ..removeWhere(
      (key, _) => {
        'title',
        'title_value',
        'edition_title',
        'age_rating',
        'audience_rating',
        'barcode',
        'upc',
        'isbn',
        'catalog_number',
        'country',
        'region',
        'cover_image_url',
        'description',
        'synopsis',
        'format',
        'physical_format',
        'language',
        'max_players',
        'min_age',
        'minimum_age',
        'min_players',
        'playing_time_minutes',
        'publisher',
        'release_date',
        'release_status',
      }.contains(key),
    );
  return {
    ...payload,
    'id': release.id,
    'title': release.title,
    if (release.editionTitle != null) 'edition_title': release.editionTitle,
    if (release.ageRating != null) 'age_rating': release.ageRating,
    if (release.audienceRating != null)
      'audience_rating': release.audienceRating,
    if (release.barcode != null) ...{
      'barcode': release.barcode,
      'upc': release.barcode,
    },
    if (release.catalogNumber != null) 'catalog_number': release.catalogNumber,
    if (release.country != null) ...{
      'country': release.country,
      'region': release.country,
    },
    if (release.coverImageUrl != null) 'cover_image_url': release.coverImageUrl,
    if (release.description != null) 'description': release.description,
    if (release.format != null) ...{
      'format': release.format,
      'physical_format': release.format,
    },
    if (release.language != null) 'language': release.language,
    if (release.maxPlayers != null) 'max_players': release.maxPlayers,
    if (release.minAge != null) 'min_age': release.minAge,
    if (release.minPlayers != null) 'min_players': release.minPlayers,
    if (release.playingTimeMinutes != null)
      'playing_time_minutes': release.playingTimeMinutes,
    if (release.publisher != null) 'publisher': release.publisher,
    if (release.releaseDate != null)
      'release_date': release.releaseDate!.toIso8601String(),
    if (release.releaseStatus != null) 'release_status': release.releaseStatus,
  };
}
