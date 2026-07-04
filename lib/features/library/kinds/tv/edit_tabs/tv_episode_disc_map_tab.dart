part of '../../../edit/library_edit_dialog.dart';

extension _LibraryEditRendererTvEpisodeDiscMapTab on _LibraryEditRendererState {
  Widget _tvEpisodeDiscMapTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Episode map',
          accent: widget.accent,
          child: FutureBuilder<TvSeries?>(
            future: _tvSeriesFuture ??= _loadTvSeriesSnapshot(),
            builder: (context, snapshot) {
              final series = snapshot.data ?? _tvSeriesSnapshot;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  series == null) {
                return const EditSectionStateMessage(
                  message: 'Loading TV episodes...',
                  icon: Icons.hourglass_empty,
                );
              }
              if (series == null) {
                return const EditSectionStateMessage(
                  message: 'No TV series data is available for this item yet.',
                  icon: Icons.tv_off_outlined,
                );
              }
              final episodes = _flattenTvEpisodes(series);
              if (episodes.isEmpty) {
                return const EditSectionStateMessage(
                  message:
                      'No episode list was returned for this series, so disc mapping cannot be edited yet.',
                  icon: Icons.route_outlined,
                );
              }
              final discNumbers = <int>{
                for (final media in _tvReleaseMediaDraft) media.discNumber ?? 1,
                if (_tvReleaseMediaDraft.isEmpty) 1,
                for (final assignment in _tvEpisodeDiscAssignments.values) assignment,
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
                                          _tvEpisodeLabel(episode),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<int>(
                                          initialValue:
                                              _tvEpisodeDiscAssignments[episode.id] ??
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
                                            _updateTvEpisodeDiscAssignment(
                                              episode.id,
                                              value,
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
