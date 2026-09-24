import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/schema/library_edit_schema_dialog.dart';
import 'package:collectarr_app/features/library/edit/core_correction/library_core_correction.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_values.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter/material.dart';

Widget buildTvReleaseLibraryEditDialog(
  BuildContext context,
  LibraryEditDialogRequest request,
) =>
    _TvReleaseSchemaEditDialog(request: request);

final class _TvReleaseSchemaEditDialog extends StatefulWidget {
  const _TvReleaseSchemaEditDialog({required this.request});

  final LibraryEditDialogRequest request;

  @override
  State<_TvReleaseSchemaEditDialog> createState() =>
      _TvReleaseSchemaEditDialogState();
}

final class _TvReleaseSchemaEditDialogState
    extends State<_TvReleaseSchemaEditDialog> {
  late final TvSeries _series;
  late final TvRelease _release;
  late final TvReleaseFormValues _draft;

  @override
  void initState() {
    super.initState();
    final transport = widget.request.kindItem.kindCapability
        .mapTransport((transport) => transport);
    final metadata = transport.kindMetadata;
    _series =
        metadata is TvSeries ? metadata : TvSeries.fromJson(transport.payload);
    _release = _resolveRelease(_series, widget.request);
    _draft = tvReleaseFormValuesFrom(_release);
  }

  @override
  Widget build(BuildContext context) =>
      LibraryEditSchemaDialog<TvRelease, TvReleaseFormValues>(
        schema: tvReleaseEditSchema,
        model: _release,
        draft: _draft,
        title: tvReleaseEditSchema.title?.call(_release) ?? 'Edit release',
        icon: widget.request.type.identity.icon,
        mediaKind: widget.request.type.kind.apiValue,
        accent: widget.request.accent,
        tabOrderKey: 'library_edit_tabs_tv_release',
        coreCorrectionSourceBuilder: () =>
            LibraryCoreCorrectionSource.fromTypedFields(
          request: widget.request,
          originalFields: _release.toJson(),
          proposedFields: tvReleaseFromFormValues(
            original: _release,
            values: _draft,
          ).toJson(),
        ),
        onCancel: () => Navigator.of(context).pop(),
        onPrevious: widget.request.onPrevious,
        onNext: widget.request.onNext,
        onSave: (_) {
          final updatedSeries = _replaceRelease(
            _series,
            tvReleaseFromFormValues(original: _release, values: _draft),
          );
          final candidate = widget.request.kindItem.kindCapability.mapTransport(
            (transport) => CatalogSearchCandidate.fromItem(
              transport.withKindMetadata(updatedSeries),
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

TvRelease _resolveRelease(
  TvSeries series,
  LibraryEditDialogRequest request,
) {
  final requestedReleaseId = switch (request.node) {
    LibraryReleaseRef(:final releaseId) => releaseId,
    LibraryCopyRef(:final releaseId) => releaseId,
    _ => null,
  };
  if (requestedReleaseId != null) {
    for (final release in series.releases) {
      if (release.id == requestedReleaseId) return release;
    }
    throw StateError(
      'TV release "$requestedReleaseId" is not present in the canonical work graph',
    );
  }
  if (!request.editPrimaryRelease) {
    throw StateError(
      'TV release edit requires an explicit release selection or primary-release intent',
    );
  }
  if (series.releases.isNotEmpty) return series.releases.first;
  throw StateError('TV release edit requires a concrete release');
}

TvSeries _replaceRelease(TvSeries series, TvRelease release) {
  return TvSeries(
    id: series.id,
    title: series.title,
    sortTitle: series.sortTitle,
    description: series.description,
    endDate: series.endDate,
    episodeCount: series.episodeCount,
    network: series.network,
    originalAirDate: series.originalAirDate,
    originalLanguage: series.originalLanguage,
    seasonCount: series.seasonCount,
    status: series.status,
    seasons: series.seasons,
    releases: [
      for (final existing in series.releases)
        existing.id == release.id ? release : existing,
    ],
    media: series.media,
    releaseEpisodeMaps: series.releaseEpisodeMaps,
    contributions: series.contributions,
    identifiers: series.identifiers,
    characterAppearances: series.characterAppearances,
    rawPayload: {
      ...series.rawPayload,
      'releases': [
        for (final existing in series.releases)
          (existing.id == release.id ? release : existing).toJson(),
      ],
    },
  );
}
