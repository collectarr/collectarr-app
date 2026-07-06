part of '../../../edit/library_edit_dialog.dart';

extension _LibraryEditRendererTvEpisodesTab on _LibraryEditRendererState {
  Widget _tvEpisodesTab() {
    final seriesRef = CatalogEntityRef(
      kind: widget.type.workspace.kind.apiValue,
      entityType: CatalogEntityType.work,
      id: widget.item.id,
    );
    final customEpisodesAsync = ref.watch(
      customEpisodesByCatalogRefProvider(seriesRef),
    );
    final trackedUnits = ref.watch(trackingUnitsByCatalogRefProvider(seriesRef));
    final watchSessions = ref.watch(watchSessionsByCatalogRefProvider(seriesRef));
    final ratingMap = _episodeRatings;
    final future = _videoEdit.tvSeriesFuture ??= _videoEdit.loadTvSeriesSnapshot();

    return EditTabShell(
      children: [
        EditSection(
          title: 'Episodes',
          accent: widget.accent,
          child: FutureBuilder<TvSeries?>(
            future: future,
            builder: (context, snapshot) {
              final series = snapshot.data ?? _videoEdit.tvSeriesSnapshot;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  series == null) {
                return const EditSectionStateMessage(
                  message: 'Loading TV episodes...',
                  icon: Icons.hourglass_empty,
                );
              }

              final seasons = _resolvedTvSeasons(series);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (series == null)
                    const EditSectionStateMessage(
                      message:
                          'No provider TV series data is available yet. Use custom episodes below.',
                      icon: Icons.edit_note,
                    )
                  else ...[
                    Text(
                      'Provider episodes',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (seasons.isEmpty)
                      const EditSectionStateMessage(
                        message:
                            'No provider episodes found for this series yet.',
                        icon: Icons.info_outline,
                      )
                    else
                      for (final season in seasons)
                        _tvSeasonEpisodeGroup(
                          context,
                          seasonTitle: 'Season ${season.seasonNumber}',
                          imageUrl: season.posterUrl ??
                              series.posterUrl ??
                              series.backdropUrl,
                          providerEpisodes: season.episodes,
                          customEpisodes: const <CustomEpisode>[],
                          seasonNumber: season.seasonNumber,
                          series: series,
                          trackedUnits: trackedUnits,
                          watchSessions: watchSessions,
                          ratingMap: ratingMap,
                        ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Custom episodes',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showManualCustomEpisodeEpisodesDialog(
                          context,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add episode'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  customEpisodesAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                    error: (_, __) => const EditSectionStateMessage(
                      message: 'Unable to load custom episodes.',
                      icon: Icons.error_outline,
                    ),
                    data: (grouped) {
                      final customEpisodes = grouped.values
                          .expand((episodes) => episodes)
                          .toList(growable: false)
                        ..sort((a, b) {
                          final seasonCompare =
                              a.seasonNumber.compareTo(b.seasonNumber);
                          if (seasonCompare != 0) {
                            return seasonCompare;
                          }
                          return a.episodeNumber.compareTo(b.episodeNumber);
                        });
                      if (customEpisodes.isEmpty) {
                        return const EditSectionStateMessage(
                          message: 'No custom episodes yet.',
                          icon: Icons.playlist_add,
                        );
                      }
                      final groupedCustomEpisodes = <int, List<CustomEpisode>>{};
                      for (final episode in customEpisodes) {
                        groupedCustomEpisodes
                            .putIfAbsent(episode.seasonNumber, () => <CustomEpisode>[])
                            .add(episode);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final entry in groupedCustomEpisodes.entries)
                            _tvSeasonEpisodeGroup(
                              context,
                              seasonTitle: 'Season ${entry.key}',
                              imageUrl: _seriesFallbackImage(series),
                              providerEpisodes: const <TvEpisode>[],
                              customEpisodes: entry.value,
                              seasonNumber: entry.key,
                              series: series,
                              trackedUnits: trackedUnits,
                              watchSessions: watchSessions,
                              ratingMap: ratingMap,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<TvSeason> _resolvedTvSeasons(TvSeries? series) {
    if (series == null) {
      return const <TvSeason>[];
    }
    if (series.seasons.isNotEmpty) {
      return series.seasons;
    }
    final episodes = _videoEdit.flattenTvEpisodes(series);
    if (episodes.isEmpty) {
      return const <TvSeason>[];
    }
    final grouped = <int, List<TvEpisode>>{};
    for (final episode in episodes) {
      grouped.putIfAbsent(episode.seasonNumber, () => <TvEpisode>[]).add(episode);
    }
    return [
      for (final entry in grouped.entries)
        TvSeason(
          id: '${series.id}:season:${entry.key}',
          seriesId: series.id,
          seasonNumber: entry.key,
          episodes: entry.value,
          posterUrl: series.posterUrl,
        ),
    ];
  }

  String? _seriesFallbackImage(TvSeries? series) {
    if (series == null) {
      return null;
    }
    return series.posterUrl ?? series.backdropUrl;
  }

  Widget _tvSeasonEpisodeGroup(
    BuildContext context, {
    required String seasonTitle,
    required String? imageUrl,
    required List<TvEpisode> providerEpisodes,
    required List<CustomEpisode> customEpisodes,
    required int seasonNumber,
    required TvSeries? series,
    required List<TrackingUnit> trackedUnits,
    required List<WatchSession> watchSessions,
    required Map<String, int> ratingMap,
  }) {
    final episodeItems = <Widget>[
      for (final episode in providerEpisodes)
        _tvEpisodeCard(
          context,
          seasonNumber: seasonNumber,
          episodeNumber: episode.episodeNumber,
          title: episode.title ?? 'Untitled',
          overview: episode.overview,
          airDate: _formatDate(episode.airDate),
          runtimeMinutes: episode.runtimeMinutes,
          imageUrl: episode.stillUrl,
          fallbackImageUrl: imageUrl,
          localImagePath: null,
          thumbnailImageUrl: null,
          discNumber: _videoEdit.tvEpisodeDiscAssignments[episode.id],
          watched: _episodeWatched(
            trackedUnits: trackedUnits,
            watchSessions: watchSessions,
            seasonNumber: seasonNumber,
            episodeNumber: episode.episodeNumber,
          ),
          rating: ratingMap[_episodeRatingKey(seasonNumber, episode.episodeNumber)],
          onEdit: null,
          onDelete: null,
        ),
      for (final episode in customEpisodes)
        _tvEpisodeCard(
          context,
          seasonNumber: episode.seasonNumber,
          episodeNumber: episode.episodeNumber,
          title: episode.title,
          overview: episode.overview,
          airDate: episode.airDate,
          runtimeMinutes: episode.runtimeMinutes,
          imageUrl: episode.stillImageUrl,
          fallbackImageUrl: _seriesFallbackImage(series),
          localImagePath: episode.localImagePath,
          thumbnailImageUrl: episode.thumbnailImageUrl,
          discNumber: null,
          watched: _episodeWatched(
            trackedUnits: trackedUnits,
            watchSessions: watchSessions,
            seasonNumber: episode.seasonNumber,
            episodeNumber: episode.episodeNumber,
          ),
          rating: ratingMap[_episodeRatingKey(episode.seasonNumber, episode.episodeNumber)],
          onEdit: () => _showManualCustomEpisodeEpisodesDialog(
            context,
            existing: episode,
          ),
          onDelete: () async {
            await ref.read(collectionMutationsProvider).removeCustomEpisode(episode);
          },
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 0,
        color: appPalette(context).panelRaised,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seasonTitle,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (episodeItems.isEmpty)
                Text(
                  'No episodes in this season.',
                  style: TextStyle(color: appPalette(context).textMuted),
                )
              else
                Column(children: episodeItems),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tvEpisodeCard(
    BuildContext context, {
    required int seasonNumber,
    required int episodeNumber,
    required String title,
    required String? overview,
    required String? airDate,
    required int? runtimeMinutes,
    required String? imageUrl,
    required String? fallbackImageUrl,
    required String? localImagePath,
    required String? thumbnailImageUrl,
    required int? discNumber,
    required bool watched,
    required int? rating,
    required VoidCallback? onEdit,
    required VoidCallback? onDelete,
  }) {
    final code =
        'S${seasonNumber.toString().padLeft(2, '0')}E${episodeNumber.toString().padLeft(2, '0')}';
    final resolvedImage = imageUrl ?? thumbnailImageUrl ?? fallbackImageUrl;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: appPalette(context).surfaceSubtle.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: widget.accent.withValues(alpha: 0.14)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EpisodeThumbnail(
                imageUrl: resolvedImage,
                localImagePath: localImagePath,
                title: title,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$code • $title',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _EpisodeMetaPill(label: watched ? 'Watched' : 'Unwatched'),
                        if (airDate != null && airDate.trim().isNotEmpty)
                          _EpisodeMetaPill(label: airDate.trim()),
                        if (runtimeMinutes != null)
                          _EpisodeMetaPill(label: '$runtimeMinutes min'),
                        if (rating != null)
                          _EpisodeMetaPill(label: 'Rating $rating'),
                        _EpisodeMetaPill(
                          label: discNumber == null
                              ? 'No disc assignment'
                              : 'Disc $discNumber',
                        ),
                      ],
                    ),
                    if (overview != null && overview.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        overview.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: appPalette(context).textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit episode',
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        visualDensity: VisualDensity.compact,
                        constraints:
                            const BoxConstraints(minWidth: 30, minHeight: 30),
                      ),
                    if (onDelete != null)
                      IconButton(
                        tooltip: 'Delete episode',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        visualDensity: VisualDensity.compact,
                        constraints:
                            const BoxConstraints(minWidth: 30, minHeight: 30),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _episodeWatched({
    required List<TrackingUnit> trackedUnits,
    required List<WatchSession> watchSessions,
    required int seasonNumber,
    required int episodeNumber,
  }) {
    final tracked = trackedUnits.any(
      (unit) =>
          unit.unitType == TrackingUnitType.episode &&
          unit.seasonNumber == seasonNumber &&
          unit.episodeNumber == episodeNumber &&
          !unit.isDeleted,
    );
    if (tracked) {
      return true;
    }
    return watchSessions.any(
      (session) =>
          session.seasonNumber == seasonNumber &&
          session.episodeNumber == episodeNumber &&
          !session.isDeleted,
    );
  }

  String _episodeRatingKey(int seasonNumber, int episodeNumber) {
    return '$seasonNumber:$episodeNumber';
  }

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }
    return value.toIso8601String().split('T').first;
  }

  Future<void> _showManualCustomEpisodeEpisodesDialog(
    BuildContext context, {
    CustomEpisode? existing,
  }) async {
    final result = await showDialog<_ManualCustomEpisodeEpisodesResult>(
      context: context,
      builder: (_) => _ManualCustomEpisodeEpisodesDialog(
        accent: widget.accent,
        title: existing == null ? 'Add custom episode' : 'Edit custom episode',
        confirmLabel: existing == null ? 'Add' : 'Save',
        initialSeasonNumber: existing?.seasonNumber ?? 1,
        initialEpisodeNumber: existing?.episodeNumber ?? 1,
        initialTitle: existing?.title ?? '',
        initialOverview: existing?.overview ?? '',
        initialAirDate: existing?.airDate ?? '',
        initialRuntimeMinutes: existing?.runtimeMinutes,
        initialStillImageUrl: existing?.stillImageUrl ?? '',
        initialLocalImagePath: existing?.localImagePath ?? '',
        initialThumbnailImageUrl: existing?.thumbnailImageUrl ?? '',
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
          stillImageUrl: result.stillImageUrl,
          localImagePath: result.localImagePath,
          thumbnailImageUrl: result.thumbnailImageUrl,
        );
  }
}

class _ManualCustomEpisodeEpisodesResult {
  const _ManualCustomEpisodeEpisodesResult({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.airDate,
    this.runtimeMinutes,
    this.stillImageUrl,
    this.localImagePath,
    this.thumbnailImageUrl,
  });

  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? overview;
  final String? airDate;
  final int? runtimeMinutes;
  final String? stillImageUrl;
  final String? localImagePath;
  final String? thumbnailImageUrl;
}

class _ManualCustomEpisodeEpisodesDialog extends StatefulWidget {
  const _ManualCustomEpisodeEpisodesDialog({
    required this.accent,
    required this.title,
    required this.confirmLabel,
    required this.initialSeasonNumber,
    required this.initialEpisodeNumber,
    required this.initialTitle,
    required this.initialOverview,
    required this.initialAirDate,
    required this.initialRuntimeMinutes,
    required this.initialStillImageUrl,
    required this.initialLocalImagePath,
    required this.initialThumbnailImageUrl,
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
  final String? initialStillImageUrl;
  final String? initialLocalImagePath;
  final String? initialThumbnailImageUrl;

  @override
  State<_ManualCustomEpisodeEpisodesDialog> createState() =>
      _ManualCustomEpisodeEpisodesDialogState();
}

class _ManualCustomEpisodeEpisodesDialogState
    extends State<_ManualCustomEpisodeEpisodesDialog> {
  late final TextEditingController _seasonController;
  late final TextEditingController _episodeController;
  late final TextEditingController _titleController;
  late final TextEditingController _overviewController;
  late final TextEditingController _airDateController;
  late final TextEditingController _runtimeController;
  late final TextEditingController _stillImageUrlController;
  late final TextEditingController _localImagePathController;
  late final TextEditingController _thumbnailImageUrlController;

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
    _overviewController =
        TextEditingController(text: widget.initialOverview ?? '');
    _airDateController = TextEditingController(text: widget.initialAirDate ?? '');
    _runtimeController = TextEditingController(
      text: widget.initialRuntimeMinutes?.toString() ?? '',
    );
    _stillImageUrlController =
        TextEditingController(text: widget.initialStillImageUrl ?? '');
    _localImagePathController =
        TextEditingController(text: widget.initialLocalImagePath ?? '');
    _thumbnailImageUrlController =
        TextEditingController(text: widget.initialThumbnailImageUrl ?? '');
  }

  @override
  void dispose() {
    _seasonController.dispose();
    _episodeController.dispose();
    _titleController.dispose();
    _overviewController.dispose();
    _airDateController.dispose();
    _runtimeController.dispose();
    _stillImageUrlController.dispose();
    _localImagePathController.dispose();
    _thumbnailImageUrlController.dispose();
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
            const SizedBox(height: 8),
            TextField(
              controller: _stillImageUrlController,
              decoration: const InputDecoration(labelText: 'Still image URL'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _thumbnailImageUrlController,
              decoration:
                  const InputDecoration(labelText: 'Thumbnail image URL'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _localImagePathController,
              decoration: const InputDecoration(labelText: 'Local image path'),
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
              _ManualCustomEpisodeEpisodesResult(
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
                stillImageUrl: _stillImageUrlController.text.trim().isEmpty
                    ? null
                    : _stillImageUrlController.text.trim(),
                localImagePath: _localImagePathController.text.trim().isEmpty
                    ? null
                    : _localImagePathController.text.trim(),
                thumbnailImageUrl:
                    _thumbnailImageUrlController.text.trim().isEmpty
                        ? null
                        : _thumbnailImageUrlController.text.trim(),
              ),
            );
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _EpisodeThumbnail extends StatelessWidget {
  const _EpisodeThumbnail({
    required this.imageUrl,
    required this.localImagePath,
    required this.title,
  });

  final String? imageUrl;
  final String? localImagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final placeholder = Container(
      color: palette.canvas,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: palette.textMuted),
    );
    Widget image;
    if (localImagePath != null && localImagePath!.trim().isNotEmpty) {
      image = Image.file(
        File(localImagePath!.trim()),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      image = Image.network(
        imageUrl!.trim(),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else {
      image = placeholder;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 100,
        height: 56,
        child: image,
      ),
    );
  }
}

class _EpisodeMetaPill extends StatelessWidget {
  const _EpisodeMetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.canvas.withValues(alpha: 0.55),
        border: Border.all(color: palette.divider.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
