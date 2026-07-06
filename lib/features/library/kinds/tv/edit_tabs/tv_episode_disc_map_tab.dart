part of '../../../edit/library_edit_dialog.dart';

extension _LibraryEditRendererTvEpisodeDiscMapTab on _LibraryEditRendererState {
  Widget _tvEpisodeDiscMapTab() {
    final customEpisodesAsync =
        ref.watch(customEpisodesByCatalogRefProvider(CatalogEntityRef(
      kind: widget.type.workspace.kind.apiValue,
      entityType: CatalogEntityType.work,
      id: widget.item.id,
    )));
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
                return _manualEpisodeFallbackSection(
                  context,
                  customEpisodesAsync,
                );
              }
              final episodes = _flattenTvEpisodes(series);
              if (episodes.isEmpty) {
                return _manualEpisodeFallbackSection(
                  context,
                  customEpisodesAsync,
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

  Widget _manualEpisodeFallbackSection(
    BuildContext context,
    AsyncValue<Map<int, List<CustomEpisode>>> customEpisodesAsync,
  ) {
    final palette = appPalette(context);
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showManualCustomEpisodeDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add episode'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (customEpisodes.isEmpty)
          Text(
            'No custom episodes yet.',
            style: TextStyle(color: palette.textMuted),
          )
        else
          for (final episode in customEpisodes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                elevation: 0,
                color: palette.panelRaised,
                child: ListTile(
                  dense: true,
                  title: Text('S${episode.seasonNumber.toString().padLeft(2, '0')}E${episode.episodeNumber.toString().padLeft(2, '0')}  ${episode.title}'),
                  subtitle: Text(
                    [
                      if (episode.overview != null &&
                          episode.overview!.trim().isNotEmpty)
                        episode.overview!.trim(),
                      if (episode.airDate != null && episode.airDate!.trim().isNotEmpty)
                        episode.airDate!,
                    ].join(' • '),
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Edit episode',
                        onPressed: () => _showManualCustomEpisodeDialog(
                          context,
                          existing: episode,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete episode',
                        onPressed: () async {
                          await ref
                              .read(collectionMutationsProvider)
                              .removeCustomEpisode(episode);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Future<void> _showManualCustomEpisodeDialog(
    BuildContext context, {
    CustomEpisode? existing,
  }) async {
    final result = await showDialog<_ManualCustomEpisodeResult>(
      context: context,
      builder: (_) => _ManualCustomEpisodeDialog(
        accent: widget.accent,
        title: existing == null ? 'Add episode' : 'Edit episode',
        confirmLabel: existing == null ? 'Add' : 'Save',
        initialSeasonNumber: existing?.seasonNumber ?? 1,
        initialEpisodeNumber: existing?.episodeNumber ?? 1,
        initialTitle: existing?.title ?? '',
        initialOverview: existing?.overview ?? '',
        initialAirDate: existing?.airDate ?? '',
        initialRuntimeMinutes: existing?.runtimeMinutes,
      ),
    );
    if (result == null || !context.mounted) {
      return;
    }
    await ref.read(collectionMutationsProvider).upsertCustomEpisode(
          id: existing?.id,
          catalogRef: CatalogEntityRef(
            kind: widget.type.workspace.kind.apiValue,
            entityType: CatalogEntityType.work,
            id: widget.item.id,
          ),
          seasonNumber: result.seasonNumber,
          episodeNumber: result.episodeNumber,
          title: result.title,
          overview: result.overview,
          airDate: result.airDate,
          runtimeMinutes: result.runtimeMinutes,
        );
  }
}

class _ManualCustomEpisodeResult {
  const _ManualCustomEpisodeResult({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.airDate,
    this.runtimeMinutes,
  });

  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? overview;
  final String? airDate;
  final int? runtimeMinutes;
}

class _ManualCustomEpisodeDialog extends StatefulWidget {
  const _ManualCustomEpisodeDialog({
    required this.accent,
    required this.title,
    required this.confirmLabel,
    required this.initialSeasonNumber,
    required this.initialEpisodeNumber,
    required this.initialTitle,
    required this.initialOverview,
    required this.initialAirDate,
    required this.initialRuntimeMinutes,
  });

  final Color accent;
  final String title;
  final String confirmLabel;
  final int initialSeasonNumber;
  final int initialEpisodeNumber;
  final String initialTitle;
  final String? initialOverview;
  final String? initialAirDate;
  final int? initialRuntimeMinutes;

  @override
  State<_ManualCustomEpisodeDialog> createState() =>
      _ManualCustomEpisodeDialogState();
}

class _ManualCustomEpisodeDialogState extends State<_ManualCustomEpisodeDialog> {
  late final TextEditingController _seasonController;
  late final TextEditingController _episodeController;
  late final TextEditingController _titleController;
  late final TextEditingController _overviewController;
  late final TextEditingController _airDateController;
  late final TextEditingController _runtimeController;

  @override
  void initState() {
    super.initState();
    _seasonController = TextEditingController(
      text: widget.initialSeasonNumber.toString(),
    );
    _episodeController = TextEditingController(
      text: widget.initialEpisodeNumber.toString(),
    );
    _titleController = TextEditingController(text: widget.initialTitle);
    _overviewController = TextEditingController(text: widget.initialOverview ?? '');
    _airDateController = TextEditingController(text: widget.initialAirDate ?? '');
    _runtimeController = TextEditingController(
      text: widget.initialRuntimeMinutes?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _seasonController.dispose();
    _episodeController.dispose();
    _titleController.dispose();
    _overviewController.dispose();
    _airDateController.dispose();
    _runtimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      title: Text(widget.title),
      accent: widget.accent,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _seasonController,
              decoration: const InputDecoration(labelText: 'Season'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _episodeController,
              decoration: const InputDecoration(labelText: 'Episode'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _overviewController,
              decoration: const InputDecoration(labelText: 'Overview'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _airDateController,
              decoration: const InputDecoration(labelText: 'Air date'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _runtimeController,
              decoration: const InputDecoration(labelText: 'Runtime (min)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final seasonNumber = int.tryParse(_seasonController.text) ?? 1;
            final episodeNumber = int.tryParse(_episodeController.text) ?? 1;
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              _ManualCustomEpisodeResult(
                seasonNumber: seasonNumber < 1 ? 1 : seasonNumber,
                episodeNumber: episodeNumber < 1 ? 1 : episodeNumber,
                title: title,
                overview: _overviewController.text.trim().isEmpty
                    ? null
                    : _overviewController.text.trim(),
                airDate: _airDateController.text.trim().isEmpty
                    ? null
                    : _airDateController.text.trim(),
                runtimeMinutes: int.tryParse(_runtimeController.text),
              ),
            );
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
