import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildAnimeMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _AnimeMediaEditDialog(request: request);

class _AnimeMediaEditDialog extends StatefulWidget {
  const _AnimeMediaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_AnimeMediaEditDialog> createState() => _AnimeMediaEditDialogState();
}

class _AnimeMediaEditDialogState extends State<_AnimeMediaEditDialog> {
  late final AnimeMedia _media;
  late final AnimeMediaEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    final canonical = transport.kindMetadata;
    _media = canonical is AnimeMedia
        ? canonical
        : AnimeMedia.fromJson(transport.payload);
    _draft = AnimeMediaEditDraft.fromMedia(_media);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<AnimeMedia, AnimeMediaEditDraft>(
        schema: animeMediaEditSchema,
        model: _media,
        draft: _draft,
        title: animeMediaEditSchema.title?.call(_media) ?? 'Edit anime',
        icon: widget.request.type.identity.icon,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_anime_media',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _media.toJson(),
          proposedFields: _draft.toMedia().toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updated = _draft.toMedia();
          final candidate = widget.request.kindItem.kindCapability.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updated),
            ),
          );
          Navigator.of(context).pop(
            LibraryEditSelection(
              kindItem: candidate,
            ),
          );
        },
      );
}
