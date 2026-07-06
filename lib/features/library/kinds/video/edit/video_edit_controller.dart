part of '../../../edit/library_edit_dialog.dart';

class VideoEditController {
  VideoEditController({
    required this.ref,
    required this.type,
    required this.item,
    required this.draft,
  });

  final WidgetRef ref;
  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final LibraryEditDraft draft;

  final List<EditableVideoCredit> castCredits = [];
  final List<EditableVideoCredit> crewCredits = [];
  final List<EditableVideoLink> externalLinkEdits = [];
  Future<TvSeries?>? tvSeriesFuture;
  TvSeries? tvSeriesSnapshot;
  List<TvReleaseMedia> tvReleaseMediaDraft = const <TvReleaseMedia>[];
  Map<String, int> tvEpisodeDiscAssignments = <String, int>{};

  TextEditingController get runtimeController => draft.runtimeController;
  TextEditingController get titleExtensionController =>
      draft.titleExtensionController;
  TextEditingController get seasonNumberController =>
      draft.seasonNumberController;
  TextEditingController get episodeNumberController =>
      draft.episodeNumberController;
  TextEditingController get audioTracksController => draft.audioTracksController;
  TextEditingController get subtitlesController => draft.subtitlesController;
  TextEditingController get layersController => draft.layersController;
  TextEditingController get colorController => draft.colorController;
  TextEditingController get nrDiscsController => draft.nrDiscsController;

  bool get isVideoKind => item.mediaKind.isVideoLibraryKind;

  bool get isTvKind => isVideoKind && type.workspace.kind.apiValue == 'tv';

  void initializeVideoEditors() {
    if (!isVideoKind) {
      return;
    }
    final creators = item.creators ?? const <Map<String, dynamic>>[];
    castCredits.addAll(
      splitVideoCredits(creators, kind: VideoCreditKind.cast),
    );
    crewCredits.addAll(
      splitVideoCredits(creators, kind: VideoCreditKind.crew),
    );
    externalLinkEdits.addAll(
      [
        for (final link in item.trailerUrls)
          if (link.isExternalLink && !link.isAutomatic)
            EditableVideoLink.fromTrailerLink(link),
      ],
    );
  }

  void dispose() {
    for (final credit in castCredits) {
      credit.dispose();
    }
    for (final credit in crewCredits) {
      credit.dispose();
    }
    for (final link in externalLinkEdits) {
      link.dispose();
    }
  }

  LibraryEditSelection applyVideoSelectionEdits(
    LibraryEditSelection selection,
  ) {
    if (!isVideoKind) {
      return selection;
    }
    return LibraryEditSelection(
      scope: selection.scope,
      item: selection.item.copyWith(
        creators: buildUpdatedVideoCreators(),
        trailerUrls: buildUpdatedTrailerUrls(selection.item.trailerUrls),
      ),
      personal: selection.personal,
      wishlist: selection.wishlist,
      tracking: selection.tracking,
      customFieldEdits: selection.customFieldEdits,
      itemImageEdits: selection.itemImageEdits,
      submitAction: selection.submitAction,
    );
  }

  List<Map<String, dynamic>>? buildUpdatedVideoCreators() {
    final merged = <Map<String, dynamic>>[
      for (final credit in castCredits) credit.toMap(),
      for (final credit in crewCredits) credit.toMap(),
    ];
    return merged.isEmpty
        ? null
        : List<Map<String, dynamic>>.unmodifiable(merged);
  }

  List<TrailerLink>? buildUpdatedTrailerUrls(List<TrailerLink> existing) {
    final preservedTrailers = existing
        .where((link) => link.isTrailerLink)
        .toList(growable: false);
    final providerExternalLinks = existing
        .where((link) => link.isExternalLink && link.isAutomatic)
        .toList(growable: false);
    final userExternalLinks = [
      for (final link in externalLinkEdits)
        if (!link.isAutomatic) link.toTrailerLink(),
    ].whereType<TrailerLink>().toList(growable: false);
    final merged = <TrailerLink>[
      ...preservedTrailers,
      ...providerExternalLinks,
      ...userExternalLinks,
    ];
    return merged.isEmpty ? null : List<TrailerLink>.unmodifiable(merged);
  }

  Future<TvSeries?> loadTvSeriesSnapshot() async {
    final api = ref.read(apiClientProvider);
    final seriesId = item.series?.seriesId ?? item.id;
    final dto = await api.getTvSeriesDto(seriesId);
    return TvSeries.fromDto(dto);
  }

  void primeTvSeriesDraft(TvSeries series) {
    tvSeriesSnapshot = series;
    tvReleaseMediaDraft = series.media.isEmpty
        ? buildFallbackTvReleaseMedia(series)
        : List<TvReleaseMedia>.from(series.media);
    tvEpisodeDiscAssignments = {
      for (final media in tvReleaseMediaDraft)
        for (final episode in media.episodes) episode.id: media.discNumber ?? 1,
    };
    if (tvEpisodeDiscAssignments.isEmpty) {
      final fallbackDisc = tvReleaseMediaDraft.isEmpty
          ? 1
          : (tvReleaseMediaDraft.first.discNumber ?? 1);
      for (final episode in flattenTvEpisodes(series)) {
        tvEpisodeDiscAssignments[episode.id] = fallbackDisc;
      }
    }
  }

  void updateTvEpisodeDiscAssignment(String episodeId, int discNumber) {
    tvEpisodeDiscAssignments[episodeId] = discNumber;
  }

  List<TvReleaseMedia> buildFallbackTvReleaseMedia(TvSeries series) {
    final episodeCount = flattenTvEpisodes(series).length;
    final discCount =
        (item.video?.nrDiscs ?? episodeCount).clamp(1, 20).toInt();
    final episodes = flattenTvEpisodes(series);
    if (discCount == 1) {
      return [
        TvReleaseMedia(
          id: '${series.id}:media:1',
          releaseId: series.id,
          title: 'Disc 1',
          formatLabel: item.physicalFormatLabel,
          discNumber: 1,
          sequenceNumber: 1,
          features: const <String>[],
          episodes: episodes,
        ),
      ];
    }
    final media = <TvReleaseMedia>[];
    for (var i = 1; i <= discCount; i++) {
      media.add(
        TvReleaseMedia(
          id: '${series.id}:media:$i',
          releaseId: series.id,
          title: 'Disc $i',
          formatLabel: item.physicalFormatLabel,
          discNumber: i,
          sequenceNumber: i,
          features: const <String>[],
          episodes: const <TvEpisode>[],
        ),
      );
    }
    return media;
  }

  List<TvEpisode> flattenTvEpisodes(TvSeries series) {
    final episodes = <TvEpisode>[];
    for (final season in series.seasons) {
      episodes.addAll(season.episodes);
    }
    if (episodes.isNotEmpty) {
      return episodes;
    }
    for (final media in series.media) {
      episodes.addAll(media.episodes);
    }
    return episodes;
  }

  String tvEpisodeLabel(TvEpisode episode) {
    final seasonPart = 'S${episode.seasonNumber.toString().padLeft(2, '0')}';
    final episodePart = 'E${episode.episodeNumber.toString().padLeft(2, '0')}';
    return '$seasonPart$episodePart ${episode.title ?? 'Episode'}';
  }
}
