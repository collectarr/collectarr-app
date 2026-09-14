import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
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
      EditSchemaRenderer<MovieMedia, MovieMediaEditDraft>(
        schema: movieMediaEditSchema,
        model: _media,
        draft: _draft,
        title: movieMediaEditSchema.title?.call(_media),
        onCancel: () => Navigator.of(context).pop(),
        onSave: (_) {
          final updated = _draft.toMedia();
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
