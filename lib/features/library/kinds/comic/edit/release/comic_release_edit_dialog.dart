import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_schema.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildComicReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) {
  return _ComicReleaseSchemaEditDialog(request: request);
}

class _ComicReleaseSchemaEditDialog extends StatefulWidget {
  const _ComicReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_ComicReleaseSchemaEditDialog> createState() =>
      _ComicReleaseSchemaEditDialogState();
}

class _ComicReleaseSchemaEditDialogState
    extends State<_ComicReleaseSchemaEditDialog> {
  late final LibraryEditShellState _editDraft;
  late final ComicRelease _release;
  late final ComicReleaseEditDraft _releaseDraft;

  @override
  void initState() {
    super.initState();
    final metadata = widget.request.kindItem
        .mapTransport((transport) => transport)
        .kindMetadata;
    if (metadata is! ComicMedia) {
      throw StateError('Expected ComicMedia for Comic release editing');
    }
    _release = _resolveRelease(
      metadata,
      widget.request,
    );
    _releaseDraft = ComicReleaseEditDraft.fromRelease(_release);
    _editDraft = LibraryEditShellState.fromRequest(widget.request);
  }

  @override
  void dispose() {
    _releaseDraft.dispose();
    _editDraft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LibraryEditSchemaDialog<ComicRelease, ComicReleaseEditDraft>(
      schema: comicReleaseEditSchema,
      model: _release,
      draft: _releaseDraft,
      title: comicReleaseEditSchema.title?.call(_release) ?? 'Edit release',
      icon: widget.request.type.identity.icon,
      accent: widget.request.accent,
      tabOrderKey: 'library_edit_tabs_comic_release',
      coreCorrectionSourceBuilder: () =>
          LibraryCoreCorrectionSource.fromTypedFields(
        request: widget.request,
        originalFields: _release.toJson(),
        proposedFields: _releaseDraft.toRelease().toJson(),
      ),
      onCancel: () => Navigator.of(context).pop(),
      onPrevious: widget.request.onPrevious,
      onNext: widget.request.onNext,
      onSave: (_) {
        final selection = _editDraft.session.saveWork(
          _editDraft,
          submitAction: LibraryEditSubmitAction.save,
        );
        final metadata = selection.kindItem
            .mapTransport((transport) => transport)
            .kindMetadata;
        if (metadata is! ComicMedia) {
          throw StateError('Expected ComicMedia for Comic release save');
        }
        final updatedRelease = _releaseDraft.toRelease();
        final updatedReleases = [
          for (final release in metadata.releases)
            release.id == _release.id ? updatedRelease : release,
        ];
        final updatedItem = selection.kindItem.mapTransport(
          (transport) => CatalogSearchCandidate.fromItem(
            transport.withKindMetadata(
              metadata.copyWith(releases: updatedReleases),
            ),
          ),
        );
        Navigator.of(context).pop(
          selection.copyWith(
            kindItem: updatedItem,
            scope: LibraryEntityScope.release,
          ),
        );
      },
    );
  }
}

ComicRelease _resolveRelease(
  ComicMedia metadata,
  LibraryEditDialogRequest request,
) {
  final requestedReleaseId = switch (request.node) {
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
    _ => null,
  };
  if (requestedReleaseId != null) {
    for (final release in metadata.releases) {
      if (release.id == requestedReleaseId) return release;
    }
    throw StateError(
      'Comic variant "$requestedReleaseId" is not present in the canonical work graph',
    );
  }
  if (!request.editPrimaryRelease) {
    throw StateError(
      'Comic variant edit requires an explicit release selection or primary-release intent',
    );
  }
  if (metadata.releases.isNotEmpty) return metadata.releases.first;
  throw StateError('Comic variant edit requires a concrete release');
}
