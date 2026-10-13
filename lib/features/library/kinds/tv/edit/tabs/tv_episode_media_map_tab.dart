import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_mutation_provider.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvEpisodeMediaMapTab extends ConsumerWidget {
  const TvEpisodeMediaMapTab({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    required this.mediaEdit,
  });

  final LibraryKindRegistration type;
  final CatalogItemDto item;
  final Color accent;
  final TvMediaEditController mediaEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customEpisodesAsync = ref.watch(
      tvCustomEpisodesByLibraryEntryRefProvider(
        LibraryEntryRef(
          kind: type.kind,
          id: LibraryEntryId(item.id),
        ),
      ),
    );
    return EditTabShell(
      children: [
        EditSection(
          title: 'Episode map',
          accent: accent,
          child: FutureBuilder<TvMetadata?>(
            future: mediaEdit.metadataFuture ??=
                mediaEdit.loadMetadataSnapshot(),
            builder: (context, snapshot) {
              final metadata = snapshot.data ?? mediaEdit.metadataSnapshot;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  metadata == null) {
                return const EditSectionStateMessage(
                  message: 'Loading TV episodes...',
                  icon: Icons.hourglass_empty,
                );
              }
              if (metadata == null) {
                return _manualEpisodeFallbackSection(
                  context,
                  accent: accent,
                  customEpisodesAsync: customEpisodesAsync,
                  type: type,
                  itemId: item.id,
                  ref: ref,
                );
              }
              final episodes = mediaEdit.flattenTvEpisodes(metadata);
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
                for (final media in mediaEdit.tvMediaDraft)
                  media.mediaNumber ?? media.position,
                if (mediaEdit.tvMediaDraft.isEmpty) 1,
                for (final assignment in mediaEdit.assignedDiscNumbers)
                  assignment,
              }.toList()
                ..sort();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EditSectionStateMessage(
                    message:
                        'Assign each episode to a disc. Changes are saved with this Catalog Item.',
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  for (final season in metadata.seasonsWithEpisodes.isNotEmpty
                      ? metadata.seasonsWithEpisodes
                      : <TvSeasonMetadata>[
                          TvSeasonMetadata(
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
                                          mediaEdit.tvEpisodeLabel(
                                            episode,
                                            seasonNumber: season.seasonNumber,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: LibraryDropdownPickField<int>(
                                          label: 'Disc',
                                          value: mediaEdit
                                                  .discAssignmentForEpisode(
                                                episodeId: episode.id ?? '',
                                                seasonNumber:
                                                    episode.seasonNumber ??
                                                        season.seasonNumber,
                                                episodeNumber:
                                                    episode.episodeNumber ??
                                                        episode.position,
                                              ) ??
                                              (discNumbers.isEmpty
                                                  ? 1
                                                  : discNumbers.first),
                                          options: [
                                            for (final disc in discNumbers)
                                              LibraryFieldOption<int>(
                                                value: disc,
                                                label: 'Disc $disc',
                                              ),
                                          ],
                                          openPicker: (
                                                  {required label,
                                                  required selectedValue,
                                                  required options}) =>
                                              showPickListSelectDialog(
                                            context: context,
                                            label: label,
                                            options: options,
                                            selectedValue: selectedValue,
                                          ),
                                          onChanged: (value) {
                                            if (value == null) {
                                              return;
                                            }
                                            mediaEdit
                                                .updateTvEpisodeDiscAssignment(
                                              episode.id ?? '',
                                              seasonNumber:
                                                  episode.seasonNumber ??
                                                      season.seasonNumber,
                                              episodeNumber:
                                                  episode.episodeNumber ??
                                                      episode.position,
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
  required AsyncValue<Map<int, List<TvCustomEpisode>>> customEpisodesAsync,
  required LibraryKindRegistration type,
  required String itemId,
  required WidgetRef ref,
}) {
  final customEpisodes = customEpisodesAsync.maybeWhen(
    data: (grouped) => grouped.values.expand((episodes) => episodes).toList(),
    orElse: () => const <TvCustomEpisode>[],
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
            'No Core TV catalog data is available yet. Add custom episodes manually below.',
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
                    if (episode.description != null &&
                        episode.description!.trim().isNotEmpty)
                      episode.description!.trim(),
                    if (episode.airDate != null) _formatDate(episode.airDate!),
                  ].join(' • '),
                ),
                trailing: IconButton(
                  tooltip: 'Delete episode',
                  onPressed: () async {
                    await ref
                        .read(tvCustomEpisodeMutationsProvider)
                        .removeCustomEpisode(episode);
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
    ],
  );
}

String _formatDate(DateTime value) => value.toIso8601String().split('T').first;
