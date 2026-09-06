import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_schema.dart';
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
  late final LibraryEditDraft _editDraft;
  late final ComicRelease _release;
  late final ComicReleaseEditDraft _releaseDraft;

  @override
  void initState() {
    super.initState();
    final metadata = widget.request.item.kindMetadata;
    if (metadata is! ComicMedia) {
      throw StateError('Expected ComicMedia for Comic release editing');
    }
    _release = _resolveRelease(
      metadata,
      widget.request.ownedItem?.anchor?.editionId,
    );
    _releaseDraft = ComicReleaseEditDraft.fromRelease(_release);
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
    return EditSchemaRenderer<ComicRelease, ComicReleaseEditDraft>(
      schema: comicReleaseEditSchema,
      model: _release,
      draft: _releaseDraft,
      title: comicReleaseEditSchema.title?.call(_release),
      onCancel: () => Navigator.of(context).pop(),
      onSave: (_) {
        final selection = _editDraft.toSelection(
          submitAction: LibraryEditSubmitAction.save,
        );
        final metadata = selection.item.kindMetadata;
        if (metadata is! ComicMedia) {
          throw StateError('Expected ComicMedia for Comic release save');
        }
        final updatedRelease = _releaseDraft.toRelease();
        final updatedReleases = [
          for (final release in metadata.releases)
            release.id == _release.id ? updatedRelease : release,
        ];
        final updatedItem = selection.item.copyWith(
          kindMetadata: metadata.copyWith(releases: updatedReleases),
        );
        Navigator.of(context).pop(
          selection.copyWith(
            item: updatedItem,
            scope: LibraryEditScope.release,
          ),
        );
      },
    );
  }
}

ComicRelease _resolveRelease(ComicMedia metadata, String? releaseId) {
  if (releaseId != null) {
    for (final release in metadata.releases) {
      if (release.id == releaseId) return release;
    }
  }
  if (metadata.releases.isNotEmpty) return metadata.releases.first;
  return ComicRelease(
    id: '',
    title: metadata.title,
    publisher: metadata.publisher,
    imprint: metadata.imprint,
    releaseDate: metadata.releaseDate,
  );
}
