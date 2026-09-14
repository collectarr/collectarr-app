import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildMusicMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MusicReleaseMediaEditDialog(request: request);

class _MusicReleaseMediaEditDialog extends StatefulWidget {
  const _MusicReleaseMediaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MusicReleaseMediaEditDialog> createState() =>
      _MusicReleaseMediaEditDialogState();
}

class _MusicReleaseMediaEditDialogState
    extends State<_MusicReleaseMediaEditDialog> {
  late final MusicRelease _release;
  late final MusicReleaseEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _release = canonical is MusicRelease
        ? canonical
        : MusicRelease.fromJson(transport.payload);
    _draft = MusicReleaseEditDraft.fromRelease(_release);
  }

  @override
  Widget build(BuildContext context) =>
      EditSchemaRenderer<MusicRelease, MusicReleaseEditDraft>(
        schema: musicReleaseEditSchema,
        model: _release,
        draft: _draft,
        title: musicReleaseEditSchema.title?.call(_release),
        onCancel: () => Navigator.of(context).pop(),
        onSave: (_) {
          final updated = _draft.toRelease();
          final candidate = widget.request.kindItem.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updated),
            ),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              item: candidate.editMetadata,
              kindItem: candidate,
              personal: null,
            ),
          );
        },
      );
}
