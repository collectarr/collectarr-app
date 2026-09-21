import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/release/manga_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/release/manga_release_edit_schema.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildMangaReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MangaReleaseSchemaEditDialog(request: request);

final class _MangaReleaseSchemaEditDialog extends StatefulWidget {
  const _MangaReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MangaReleaseSchemaEditDialog> createState() =>
      _MangaReleaseSchemaEditDialogState();
}

final class _MangaReleaseSchemaEditDialogState
    extends State<_MangaReleaseSchemaEditDialog> {
  late final MangaMetadata _metadata;
  late final CatalogEditionDto _release;
  late final MangaReleaseEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final metadata = transport.kindMetadata;
    _metadata = metadata is MangaMetadata
        ? metadata
        : MangaMetadata.fromJson(transport.toSyncPayload());
    _release = _resolveRelease(_metadata, widget.request);
    _draft = MangaReleaseEditDraft.fromRelease(_release);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<CatalogEditionDto, MangaReleaseEditDraft>(
        schema: mangaReleaseEditSchema,
        model: _release,
        draft: _draft,
        title: mangaReleaseEditSchema.title?.call(_release) ?? 'Edit edition',
        icon: widget.request.type.identity.icon,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_manga_release',
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updatedMetadata =
              _replaceRelease(_metadata, _draft.toRelease());
          final candidate = widget.request.kindItem.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updatedMetadata),
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

CatalogEditionDto _resolveRelease(
  MangaMetadata metadata,
  LibraryEditDialogRequest request,
) {
  final requestedReleaseId = switch (request.node) {
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
    _ => null,
  };
  if (requestedReleaseId != null) {
    for (final release in metadata.editions) {
      if (release.id == requestedReleaseId) return release;
    }
    throw StateError(
      'Manga release "$requestedReleaseId" is not present in the canonical work graph',
    );
  }
  if (!request.editPrimaryRelease) {
    throw StateError(
      'Manga release edit requires an explicit release selection or primary-release intent',
    );
  }
  if (metadata.editions.isNotEmpty) return metadata.editions.first;
  throw StateError('Manga release edit requires a concrete release');
}

MangaMetadata _replaceRelease(
  MangaMetadata metadata,
  CatalogEditionDto release,
) {
  return metadata.copyWith(
    editions: [
      for (final existing in metadata.editions)
        existing.id == release.id ? release : existing,
    ],
  );
}
