import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_draft.dart';
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
  late final GameReleaseEditDraft _draft;

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
    _draft = GameReleaseEditDraft.fromRelease(_release);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<GameRelease, GameReleaseEditDraft>(
        schema: gameReleaseEditSchema,
        model: _release,
        draft: _draft,
        title: gameReleaseEditSchema.title?.call(_release) ?? 'Edit release',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_game_release',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _release.toJson(),
          proposedFields: _draft.toRelease().toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updatedMedia = _replaceRelease(_media, _draft.toRelease());
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

GameMedia _replaceRelease(GameMedia media, GameRelease release) {
  final releases = [
    for (final existing in media.releases)
      existing.id == release.id ? release : existing,
  ];
  return GameMedia(
    id: media.id,
    title: media.title,
    sortTitle: media.sortTitle,
    description: media.description,
    releaseDate: media.releaseDate,
    originalLanguage: media.originalLanguage,
    publisher: media.publisher,
    subtitle: media.subtitle,
    platforms: media.platforms,
    identifiers: media.identifiers,
    companyRoles: media.companyRoles,
    ageRatings: media.ageRatings,
    genres: media.genres,
    searchAliases: media.searchAliases,
    releases: releases,
    rawPayload: {
      ...media.rawPayload,
      'releases': releases.map((entry) => entry.toJson()).toList(),
    },
  );
}
