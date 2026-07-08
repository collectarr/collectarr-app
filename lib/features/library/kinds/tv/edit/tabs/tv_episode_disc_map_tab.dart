import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/shared/video/edit/video_edit_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvEpisodeDiscMapTab extends ConsumerWidget {
  const TvEpisodeDiscMapTab({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    required this.videoEdit,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customEpisodesAsync = ref.watch(
      customEpisodesByCatalogRefProvider(
        CatalogEntityRef(
          kind: type.workspace.kind.apiValue,
          entityType: CatalogEntityType.work,
          id: item.id,
        ),
      ),
    );
    return EditTabShell(
      children: [
        EditSection(
          title: 'Episode map',
          accent: accent,
          child: FutureBuilder<TvSeries?>(
            future: videoEdit.tvSeriesFuture ??= videoEdit.loadTvSeriesSnapshot(),
            builder: (context, snapshot) {
              final series = snapshot.data ?? videoEdit.tvSeriesSnapshot;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  series == null) {
                return const EditSectionStateMessage(
                  message: 'Loading TV episodes...',
                  icon: Icons.hourglass_empty,
                );
              }
              if (series == null) {
                return _manualEpisodeFallbackSection(
                  context,
                  accent: accent,
                  customEpisodesAsync: customEpisodesAsync,
                  type: type,
                  itemId: item.id,
                  ref: ref,
                );
              }
              final episodes = videoEdit.flattenTvEpisodes(series);
              if (episodes.isEmpty) {
                return _manualEpisodeFallbackSection(
                  context,
                  accent: accent,
                  customEpisodesAsync: customEpisodesAsync,
                  type: type,
                  itemId: item.id,
                  ref: ref,
                );
              }
              final discNumbers = <int>{
                for (final media in videoEdit.tvReleaseMediaDraft)
                  media.discNumber ?? 1,
                if (videoEdit.tvReleaseMediaDraft.isEmpty) 1,
                for (final assignment in videoEdit.tvEpisodeDiscAssignments.values)
                  assignment,
              }.toList()
                ..sort();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EditSectionStateMessage(
                    message:
                        'Move episodes between discs here. The current mapping is staged locally in the dialog.',
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  for (final season in series.seasons.isNotEmpty
                      ? series.seasons
                      : <TvSeason>[
                          TvSeason(
                            id: '${series.id}:season:1',
                            seriesId: series.id,
                            seasonNumber: 1,
                            episodes: episodes,
                          ),
                        ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 0,
                        color: appPalette(context).panelRaised,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Season ${season.seasonNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              for (final episode in season.episodes.isNotEmpty
                                  ? season.episodes
                                  : episodes.where(
                                      (episode) =>
                                          episode.seasonNumber ==
                                          season.seasonNumber,
                                    ))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          videoEdit.tvEpisodeLabel(episode),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<int>(
                                          initialValue: videoEdit
                                                  .tvEpisodeDiscAssignments[
                                              episode.id] ??
                                              (discNumbers.isEmpty
                                                  ? 1
                                                  : discNumbers.first),
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Disc',
                                          ),
                                          items: [
                                            for (final disc in discNumbers)
                                              DropdownMenuItem<int>(
                                                value: disc,
                                                child: Text('Disc $disc'),
                                              ),
                                          ],
                                          onChanged: (value) {
                                            if (value == null) {
                                              return;
                                            }
                                            videoEdit.updateTvEpisodeDiscAssignment(
                                              episode.id,
                                              seasonNumber: episode.seasonNumber,
                                              episodeNumber: episode.episodeNumber,
                                              discNumber: value,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget _manualEpisodeFallbackSection(
  BuildContext context, {
  required Color accent,
  required AsyncValue<Map<int, List<CustomEpisode>>> customEpisodesAsync,
  required LibraryTypeConfig type,
  required String itemId,
  required WidgetRef ref,
}) {
  final customEpisodes = customEpisodesAsync.maybeWhen(
    data: (grouped) => grouped.values.expand((episodes) => episodes).toList(),
    orElse: () => const <CustomEpisode>[],
  )..sort((a, b) {
      final seasonCompare = a.seasonNumber.compareTo(b.seasonNumber);
      if (seasonCompare != 0) return seasonCompare;
      return a.episodeNumber.compareTo(b.episodeNumber);
    });
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const EditSectionStateMessage(
        message:
            'No provider TV series data is available yet. Add custom episodes manually below.',
        icon: Icons.edit_note,
      ),
      const SizedBox(height: 12),
      if (customEpisodes.isEmpty)
        Text(
          'No custom episodes yet.',
          style: TextStyle(color: appPalette(context).textMuted),
        )
      else
        for (final episode in customEpisodes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: 0,
              color: appPalette(context).panelRaised,
              child: ListTile(
                dense: true,
                title: Text(
                  'S${episode.seasonNumber.toString().padLeft(2, '0')}E${episode.episodeNumber.toString().padLeft(2, '0')}  ${episode.title}',
                ),
                subtitle: Text(
                  [
                    if (episode.overview != null &&
                        episode.overview!.trim().isNotEmpty)
                      episode.overview!.trim(),
                    if (episode.airDate != null &&
                        episode.airDate!.trim().isNotEmpty)
                      episode.airDate!,
                  ].join(' • '),
                ),
                trailing: IconButton(
                  tooltip: 'Delete episode',
                  onPressed: () async {
                    await ref.read(collectionMutationsProvider).removeCustomEpisode(episode);
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
    ],
  );
}
