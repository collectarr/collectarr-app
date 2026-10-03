import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_user_links_section.dart';
import 'package:collectarr_app/features/library/detail/library_external_links_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/hierarchy/tv_upcoming_episodes_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_seasons_provider.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_episode_rating_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_progress_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_season_tracking_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/tracking/session_history_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildTvVideoDetailContribution(
  BuildContext context,
  LibraryDetailPageRequest request,
) {
  return TvVideoDetailContribution(request: request);
}

/// TV's detail view presents episodes and viewing activity contained by one
/// Catalog Item. Physical editions are Catalog Items themselves, not children
/// browsed from this panel.
final class TvVideoDetailContribution extends ConsumerWidget {
  const TvVideoDetailContribution({super.key, required this.request});

  final LibraryDetailPageRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = this.request;
    final catalogRef = CatalogEntityRef(
      kind: request.type.kind,
      entityType: CatalogEntityTypeId.catalogItem,
      id: request.item.source.itemId,
    );
    final seasonsAsync = ref.watch(tvSeasonsByCatalogRefProvider(catalogRef));
    final watchTargets = _watchHistoryTargets(
      request: request,
      catalogRef: catalogRef,
      seasonsAsync: seasonsAsync,
    );
    final catalog = request.item.source.catalogData;
    final links = catalog is TvWorkspaceCatalogData
        ? catalog.metadata?.links ?? const <TrailerLinkDto>[]
        : const <TrailerLinkDto>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VideoProgressSection(
          seriesRef: catalogRef,
          accent: request.accent,
        ),
        const SizedBox(height: 16),
        VideoSeasonTrackingSection(
          seriesRef: catalogRef,
          kind: request.type.kind.apiValue,
          accent: request.accent,
        ),
        const SizedBox(height: 16),
        TvEpisodeRatingDisplaySection(
          itemId: request.item.source.itemId,
          accent: request.accent,
        ),
        const SizedBox(height: 16),
        LibraryExternalLinksSection(
          title: 'External links',
          links: links,
          accent: request.accent,
        ),
        const SizedBox(height: 16),
        LibraryDetailUserLinksSection(
          libraryEntryRef: request.libraryEntrySummary?.ref,
          accent: request.accent,
        ),
        const SizedBox(height: 16),
        TvUpcomingEpisodesSection(
          seriesRef: catalogRef,
          accent: request.accent,
        ),
        const SizedBox(height: 16),
        WatchHistorySection(
          libraryEntryRef: request.libraryEntrySummary?.ref ??
              LibraryEntryRef(
                kind: catalogRef.mediaKind,
                id: LibraryEntryId(request.item.source.itemId),
              ),
          accent: request.accent,
          targetOptions: watchTargets,
        ),
      ],
    );
  }
}

List<WatchHistoryTargetOption> _watchHistoryTargets({
  required LibraryDetailPageRequest request,
  required CatalogEntityRef catalogRef,
  required AsyncValue<List<TvSeason>> seasonsAsync,
}) =>
    [
      WatchHistoryTargetOption(
        label: 'This item',
        subtitle: request.item.source.title,
      ),
      ...seasonsAsync.maybeWhen(
        data: (seasons) => [
          for (final season in seasons) ...[
            WatchHistoryTargetOption(
              label: season.title ?? 'Season ${season.seasonNumber ?? 0}',
              subtitle: 'Season ${season.seasonNumber ?? 0}',
              seasonNumber: season.seasonNumber,
            ),
            for (final episode in season.episodes)
              WatchHistoryTargetOption(
                label: episode.title ?? 'Episode ${episode.episodeNumber ?? 0}',
                seasonNumber: season.seasonNumber,
                episodeNumber: episode.episodeNumber?.toInt(),
                episodeId: episode.id,
                subtitle:
                    'Season ${season.seasonNumber} • Episode ${episode.episodeNumber}',
              ),
          ],
        ],
        orElse: () => const <WatchHistoryTargetOption>[],
      ),
    ];
