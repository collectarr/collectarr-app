import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_draft.dart';
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
  late final BoardGameEditionEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _media = canonical is BoardGameMedia
        ? canonical
        : BoardGameMedia.fromJson(transport.payload);
    _edition = _resolveEdition(
      _media,
      widget.request,
    );
    _draft = BoardGameEditionEditDraft.fromRelease(_edition);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<BoardGameEdition, BoardGameEditionEditDraft>(
        schema: boardGameEditionEditSchema,
        model: _edition,
        draft: _draft,
        title:
            boardGameEditionEditSchema.title?.call(_edition) ?? 'Edit edition',
        icon: widget.request.type.identity.icon,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_boardgame_release',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _edition.toJson(),
          proposedFields: _draft.toRelease().toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updatedMedia = _replaceEdition(_media, _draft.toRelease());
          final candidate = widget.request.kindItem.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updatedMedia),
            ),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              item: candidate.editMetadata,
              kindItem: candidate,
              personal: null,
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

BoardGameMedia _replaceEdition(
  BoardGameMedia media,
  BoardGameEdition edition,
) {
  final editions = [
    for (final existing in media.editions)
      existing.id == edition.id ? edition : existing,
  ];
  return BoardGameMedia(
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
    contributors: media.contributors,
    mechanics: media.mechanics,
    categories: media.categories,
    families: media.families,
    expansions: media.expansions,
    rankings: media.rankings,
    searchAliases: media.searchAliases,
    editions: editions,
    rawPayload: {
      ...media.rawPayload,
      'editions': editions.map((entry) => entry.toJson()).toList(),
    },
  );
}
