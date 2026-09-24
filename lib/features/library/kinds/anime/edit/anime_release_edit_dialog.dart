import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_values.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildAnimeReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _AnimeReleaseSchemaEditDialog(request: request);

final class _AnimeReleaseSchemaEditDialog extends StatefulWidget {
  const _AnimeReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_AnimeReleaseSchemaEditDialog> createState() =>
      _AnimeReleaseSchemaEditDialogState();
}

final class _AnimeReleaseSchemaEditDialogState
    extends State<_AnimeReleaseSchemaEditDialog> {
  late final AnimeMedia _media;
  late final AnimeRelease _release;
  late final AnimeReleaseFormValues _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    final metadata = transport.kindMetadata;
    _media = metadata is AnimeMedia
        ? metadata
        : AnimeMedia.fromJson(transport.payload);
    _release = _resolveRelease(_media, widget.request);
    _draft = animeReleaseFormValuesFrom(_release);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<AnimeRelease, AnimeReleaseFormValues>(
        schema: animeReleaseEditSchema,
        model: _release,
        draft: _draft,
        title: animeReleaseEditSchema.title?.call(_release) ?? 'Edit release',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_anime_release',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _release.toJson(),
          proposedFields: animeReleaseFromFormValues(
            original: _release,
            values: _draft,
          ).toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updatedMedia = _replaceRelease(
            _media,
            animeReleaseFromFormValues(original: _release, values: _draft),
          );
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

AnimeRelease _resolveRelease(
  AnimeMedia media,
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
      'Anime release "$requestedReleaseId" is not present in the canonical work graph',
    );
  }
  if (!request.editPrimaryRelease) {
    throw StateError(
      'Anime release edit requires an explicit release selection or primary-release intent',
    );
  }
  final primary = media.primaryRelease;
  if (primary != null) return primary;
  throw StateError('Anime release edit requires a concrete release');
}

AnimeMedia _replaceRelease(AnimeMedia media, AnimeRelease release) {
  return AnimeMedia(
    id: media.id,
    title: media.title,
    animeType: media.animeType,
    characterAppearances: media.characterAppearances,
    contributions: media.contributions,
    description: media.description,
    endDate: media.endDate,
    episodeCount: media.episodeCount,
    episodes: media.episodes,
    identifiers: media.identifiers,
    originalAirDate: media.originalAirDate,
    originalLanguage: media.originalLanguage,
    sortTitle: media.sortTitle,
    status: media.status,
    releases: [
      for (final existing in media.releases)
        existing.id == release.id ? release : existing,
    ],
    rawPayload: {
      ...media.rawPayload,
      'releases': [
        for (final existing in media.releases)
          (existing.id == release.id ? release : existing).toJson(),
      ],
    },
  );
}
