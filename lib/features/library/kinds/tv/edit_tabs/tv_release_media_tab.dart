part of '../../../edit/library_edit_dialog.dart';

extension _LibraryEditRendererTvReleaseMediaTab on _LibraryEditRendererState {
  Widget _tvReleaseMediaTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Release media',
          accent: widget.accent,
          child: FutureBuilder<TvSeries?>(
            future: _videoEdit.tvSeriesFuture ??= _videoEdit.loadTvSeriesSnapshot(),
            builder: (context, snapshot) {
              final series = snapshot.data ?? _videoEdit.tvSeriesSnapshot;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  series == null) {
                return const EditSectionStateMessage(
                  message: 'Loading TV release media...',
                  icon: Icons.hourglass_empty,
                );
              }
              if (series == null) {
                return const EditSectionStateMessage(
                  message: 'No TV series data is available for this item yet.',
                  icon: Icons.tv_off_outlined,
                );
              }
              final media = _videoEdit.tvReleaseMediaDraft.isEmpty
                  ? _videoEdit.buildFallbackTvReleaseMedia(series)
                  : _videoEdit.tvReleaseMediaDraft;
              if (media.isEmpty) {
                return const EditSectionStateMessage(
                  message: 'No release media is available for this series.',
                  icon: Icons.album_outlined,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EditSectionStateMessage(
                    message:
                        'Disc metadata is editable here; episode assignments are staged in the Episode map tab.',
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  for (final disc in media)
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.album_outlined,
                                    size: 18,
                                    color: appPalette(context).textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    disc.title ?? 'Disc ${disc.discNumber ?? 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Disc ${disc.discNumber ?? 1}',
                                    style: TextStyle(
                                      color: appPalette(context).textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (disc.formatLabel != null) ...[
                                const SizedBox(height: 8),
                                Text('Format: ${disc.formatLabel}'),
                              ],
                              if (disc.features.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Features: ${disc.features.join(', ')}'),
                              ],
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final episode in disc.episodes.isNotEmpty
                                      ? disc.episodes
                                      : _videoEdit.flattenTvEpisodes(series)
                                          .where(
                                            (episode) =>
                                                _videoEdit.tvEpisodeDiscAssignments[episode.id] ==
                                                (disc.discNumber ?? 1),
                                          ))
                                    Chip(
                                      label: Text(
                                        _videoEdit.tvEpisodeLabel(episode),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
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
