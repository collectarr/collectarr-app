import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_media_edit_schema.dart';
import 'package:flutter/material.dart';

Widget buildMovieMediaLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MovieMediaEditDialog(request: request);

class _MovieMediaEditDialog extends StatefulWidget {
  const _MovieMediaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MovieMediaEditDialog> createState() => _MovieMediaEditDialogState();
}

class _MovieMediaEditDialogState extends State<_MovieMediaEditDialog> {
  late final MovieMedia _media;
  late final MovieMediaEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final canonical = transport.kindMetadata;
    _media = canonical is MovieMedia
        ? canonical
        : MovieMedia.fromJson(transport.payload);
    _draft = MovieMediaEditDraft.fromMedia(_media);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<MovieMedia, MovieMediaEditDraft>(
        schema: movieMediaEditSchema,
        model: _media,
        draft: _draft,
        title: movieMediaEditSchema.title?.call(_media) ?? 'Edit movie',
        icon: widget.request.type.identity.icon,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_movie_media',
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
          final candidate = widget.request.kindItem.mapTransport(
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
