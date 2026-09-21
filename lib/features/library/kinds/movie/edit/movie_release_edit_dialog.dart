import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_release_edit_schema.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildMovieReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _MovieReleaseSchemaEditDialog(request: request);

final class _MovieReleaseSchemaEditDialog extends StatefulWidget {
  const _MovieReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_MovieReleaseSchemaEditDialog> createState() =>
      _MovieReleaseSchemaEditDialogState();
}

final class _MovieReleaseSchemaEditDialogState
    extends State<_MovieReleaseSchemaEditDialog> {
  late final MovieMedia _media;
  late final MovieRelease _release;
  late final MovieReleaseEditDraft _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.toTransport();
    final metadata = transport.kindMetadata;
    _media = metadata is MovieMedia
        ? metadata
        : MovieMedia.fromJson(transport.payload);
    _release = _resolveRelease(_media, widget.request);
    _draft = MovieReleaseEditDraft.fromRelease(_release);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<MovieRelease, MovieReleaseEditDraft>(
        schema: movieReleaseEditSchema,
        model: _release,
        draft: _draft,
        title: movieReleaseEditSchema.title?.call(_release) ?? 'Edit release',
        icon: widget.request.type.identity.icon,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_movie_release',
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updatedMedia = _replaceRelease(_media, _draft.toRelease());
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

MovieRelease _resolveRelease(
  MovieMedia media,
  LibraryEditDialogRequest request,
) {
  final requestedReleaseId = switch (request.node) {
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
    _ => null,
  };
  if (requestedReleaseId != null) {
    for (final release in media.releases) {
      if (release.id.value == requestedReleaseId) return release;
    }
    throw StateError(
      'Movie release "$requestedReleaseId" is not present in the canonical work graph',
    );
  }
  if (!request.editPrimaryRelease) {
    throw StateError(
      'Movie release edit requires an explicit release selection or primary-release intent',
    );
  }
  final primary = media.primaryRelease;
  if (primary != null) return primary;
  throw StateError('Movie release edit requires a concrete release');
}

MovieMedia _replaceRelease(MovieMedia media, MovieRelease release) {
  return MovieMedia(
    id: media.id,
    title: media.title,
    ageRating: media.ageRating,
    audienceRating: media.audienceRating,
    characterAppearances: media.characterAppearances,
    contributions: media.contributions,
    description: media.description,
    externalLinks: media.externalLinks,
    identifiers: media.identifiers,
    originalLanguage: media.originalLanguage,
    releaseDate: media.releaseDate,
    releases: [
      for (final existing in media.releases)
        existing.id == release.id ? release : existing,
    ],
    runtimeMinutes: media.runtimeMinutes,
    sortTitle: media.sortTitle,
    subtitle: media.subtitle,
    trailerUrls: media.trailerUrls,
    rawPayload: {
      ...media.rawPayload,
      'releases': [
        for (final existing in media.releases)
          (existing.id == release.id ? release : existing).toJson(),
      ],
    },
  );
}
