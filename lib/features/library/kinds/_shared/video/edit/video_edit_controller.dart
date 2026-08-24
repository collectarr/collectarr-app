import 'dart:async';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/core/api/mappers/tv_mapper.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_runtime.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/domain/video_episode.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'video_edit_models.dart';
import 'video_kind_edit_draft.dart';

class VideoEditController {
  VideoEditController({
    this.ref,
    this.type,
    required this.item,
    this.draft,
    String? initialRuntime,
    String? initialSeasonNumber,
    String? initialEpisodeNumber,
    Map<String, int>? initialEpisodeRatings,
    this.initialCreators = const <Map<String, dynamic>>[],
    this.initialDiscCount,
  })  : runtimeController = TextEditingController(
          text: initialRuntime ??
              (item.kindMetadata
                      .toSyncPayload()['runtime_minutes']
                      ?.toString() ??
                  ''),
        ),
        seasonNumberController = TextEditingController(
          text: initialSeasonNumber ??
              item.series?.seasonNumber?.toString() ??
              '',
        ),
        episodeNumberController = TextEditingController(
          text: initialEpisodeNumber ??
              item.series?.episodeNumber?.toString() ??
              '',
        ),
        ageRatingController = TextEditingController(text: item.ageRating ?? ''),
        audienceRatingController =
            TextEditingController(text: item.audienceRating ?? ''),
        genresEditController = TextEditingController(
          text: ((item.kindMetadata.toSyncPayload()['genres'] as List?)
                      ?.map((e) => e.toString()) ??
                  const <String>[])
              .join(', '),
        ),
        episodeRatings =
            Map<String, int>.from(initialEpisodeRatings ?? const {});

  final WidgetRef? ref;
  final LibraryTypeConfig? type;
  final LibraryMetadataItem item;
  final LibraryEditDraft? draft;
  final List<Map<String, dynamic>> initialCreators;
  final int? initialDiscCount;

  final TextEditingController runtimeController;
  final TextEditingController seasonNumberController;
  final TextEditingController episodeNumberController;
  final TextEditingController ageRatingController;
  final TextEditingController audienceRatingController;
  final TextEditingController genresEditController;
  final Map<String, int> episodeRatings;

  final List<EditableVideoCredit> castCredits = [];
  final List<EditableVideoCredit> crewCredits = [];
  final List<EditableUserExternalLink> userLinkEdits = [];
  final List<EditableUserExternalLink> userTrailerEdits = [];
  Future<TvSeries?>? tvSeriesFuture;
  TvSeries? tvSeriesSnapshot;
  List<TvReleaseMedia> tvReleaseMediaDraft = const <TvReleaseMedia>[];
  Map<String, int> tvEpisodeDiscAssignments = <String, int>{};

  VideoKindEditDraft? get _videoDraft =>
      draft?.kindDetails is VideoKindEditDraft
          ? draft!.kindDetails as VideoKindEditDraft
          : null;
  static final _dummyController = TextEditingController();

  TextEditingController get audioTracksController =>
      _videoDraft?.audioTracksController ?? _dummyController;
  TextEditingController get subtitlesController =>
      _videoDraft?.subtitlesController ?? _dummyController;
  TextEditingController get layersController =>
      _videoDraft?.layersController ?? _dummyController;
  TextEditingController get colorController =>
      _videoDraft?.colorController ?? _dummyController;
  TextEditingController get nrDiscsController =>
      _videoDraft?.nrDiscsController ?? _dummyController;

  bool get isVideoKind => item.mediaKind.isVideoLibraryKind;

  bool get isTvKind =>
      isVideoKind &&
      (type?.workspace.kind.apiValue ?? item.mediaKind.apiValue) == 'tv';

  void initializeVideoEditors() {
    if (!isVideoKind) {
      return;
    }
    final creators = initialCreators;
    castCredits.addAll(
      splitVideoCredits(creators, kind: VideoCreditKind.cast),
    );
    crewCredits.addAll(
      splitVideoCredits(creators, kind: VideoCreditKind.crew),
    );
  }

  Future<void> loadUserExternalLinks() async {
    if (!isVideoKind || ref == null) {
      return;
    }
    final db = ref!.read(localDatabaseProvider);
    final repo = UserExternalLinksCacheRepository(db);
    final links = [
      ...await repo.listByItemId(item.id),
      for (final link in item.trailerUrls.where((link) => !link.isAutomatic))
        UserExternalLink(
          id: 'seed-${item.id}-${link.kind}-${link.url.hashCode}',
          itemId: item.id,
          label: link.title ?? link.description ?? link.url,
          url: link.url,
          kind: link.kind == 'trailer' ? 'trailer' : 'custom',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
    ];
    final seen = <String>{};
    for (final link in links) {
      final key = '${link.kind}|${link.label}|${link.url}';
      if (!seen.add(key)) {
        continue;
      }
      final editable = EditableUserExternalLink.fromUserExternalLink(link);
      if (editable.kind == 'trailer') {
        userTrailerEdits.add(editable);
      } else {
        userLinkEdits.add(editable);
      }
    }
  }

  void dispose() {
    runtimeController.dispose();
    seasonNumberController.dispose();
    episodeNumberController.dispose();
    ageRatingController.dispose();
    audienceRatingController.dispose();
    genresEditController.dispose();
    for (final credit in castCredits) {
      credit.dispose();
    }
    for (final credit in crewCredits) {
      credit.dispose();
    }
    for (final link in userLinkEdits) {
      link.dispose();
    }
    for (final link in userTrailerEdits) {
      link.dispose();
    }
  }

  LibraryEditSelection applyVideoSelectionEdits(
    LibraryEditSelection selection,
  ) {
    if (!isVideoKind) {
      return selection;
    }
    final currentSeries = selection.item.series;
    final updatedSeries = currentSeries == null
        ? null
        : CatalogSeriesDetails(
            seriesId: currentSeries.seriesId,
            seriesTitle: currentSeries.seriesTitle,
            volumeName: currentSeries.volumeName,
            volumeNumber: currentSeries.volumeNumber,
            volumeStartYear: currentSeries.volumeStartYear,
            seasonNumber: int.tryParse(seasonNumberController.text) ??
                currentSeries.seasonNumber,
            episodeNumber: int.tryParse(episodeNumberController.text) ??
                currentSeries.episodeNumber,
            tags: currentSeries.tags,
          );
    final updatedTracking = selection.tracking?.copyWith(
      seasonNumber: int.tryParse(seasonNumberController.text),
      episodeNumber: int.tryParse(episodeNumberController.text),
      episodeRatings: episodeRatings.isEmpty ? null : episodeRatings,
    );
    final parsedGenres = genresEditController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final payload = selection.item.kindMetadata.toSyncPayload();
    final updatedLinks = buildUpdatedTrailerUrls(selection.item.trailerUrls);
    final updatedPayload = {
      ...payload,
      if (int.tryParse(runtimeController.text) != null)
        'runtime_minutes': int.tryParse(runtimeController.text),
      if (updatedSeries case final s?) ...{
        'series_id': s.seriesId,
        'series_title': s.seriesTitle,
        'volume_name': s.volumeName,
        'volume_number': s.volumeNumber,
        'volume_start_year': s.volumeStartYear,
        'season_number': s.seasonNumber,
        'episode_number': s.episodeNumber,
        'tags': s.tags,
      },
      'age_rating': emptyToNull(ageRatingController.text),
      'audience_rating': emptyToNull(audienceRatingController.text),
      if (parsedGenres.isNotEmpty) 'genres': parsedGenres,
      if (buildUpdatedVideoCreators() != null)
        'creators': buildUpdatedVideoCreators(),
      if (updatedLinks != null)
        'external_links': updatedLinks.map((l) => l.toJson()).toList(),
    };
    final updatedItem = LibraryMetadataItem(
      identity: selection.item.identity,
      common: selection.item.common,
      kindMetadata: LibraryKindMetadataDecoders.decode(
        selection.item.mediaKind,
        updatedPayload,
      ),
    );
    return LibraryEditSelection(
      scope: selection.scope,
      item: updatedItem,
      personal: selection.personal,
      wishlist: selection.wishlist,
      tracking: updatedTracking ?? selection.tracking,
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
        .where((link) => link.isTrailerLink && link.isAutomatic)
        .toList(growable: false);
    final providerExternalLinks = existing
        .where((link) => link.isExternalLink && link.isAutomatic)
        .toList(growable: false);
    final merged = <TrailerLink>[
      ...preservedTrailers,
      ...providerExternalLinks,
    ];
    return merged.isEmpty ? null : List<TrailerLink>.unmodifiable(merged);
  }

  Future<void> persistUserExternalLinks() async {
    if (!isVideoKind || ref == null) {
      return;
    }
    final db = ref!.read(localDatabaseProvider);
    final repo = UserExternalLinksCacheRepository(db);
    final links = <UserExternalLink>[];
    for (final link in userLinkEdits) {
      final resolved = link.toUserExternalLink(itemId: item.id);
      if (resolved != null) {
        links.add(resolved);
      }
    }
    for (final link in userTrailerEdits) {
      final resolved = link.toUserExternalLink(itemId: item.id);
      if (resolved != null) {
        links.add(resolved);
      }
    }
    await repo.replaceForItem(item.id, links);
  }

  Future<TvSeries?> loadTvSeriesSnapshot() async {
    if (ref == null) return null;
    final api = ref!.read(apiClientProvider);
    final seriesId = item.series?.seriesId ?? item.id;
    try {
      final dto = await api
          .getTvSeriesDto(seriesId)
          .timeout(const Duration(seconds: 20));
      return tvSeriesFromDto(dto);
    } on TimeoutException {
      return null;
    }
  }

  void primeTvSeriesDraft(TvSeries series) {
    tvSeriesSnapshot = series;
    tvReleaseMediaDraft = series.media.isEmpty
        ? buildFallbackTvReleaseMedia(series)
        : List<TvReleaseMedia>.from(series.media);
    tvEpisodeDiscAssignments = {
      for (final media in tvReleaseMediaDraft)
        for (final episode in media.episodes) ...{
          episode.id: media.discNumber ?? 1,
          '${episode.seasonNumber}:${episode.episodeNumber}':
              media.discNumber ?? 1,
        },
    };
    if (tvEpisodeDiscAssignments.isEmpty) {
      final fallbackDisc = tvReleaseMediaDraft.isEmpty
          ? 1
          : (tvReleaseMediaDraft.first.discNumber ?? 1);
      for (final episode in flattenTvEpisodes(series)) {
        tvEpisodeDiscAssignments[episode.id] = fallbackDisc;
        tvEpisodeDiscAssignments[
            '${episode.seasonNumber}:${episode.episodeNumber}'] = fallbackDisc;
      }
    }
  }

  void updateTvEpisodeDiscAssignment(
    String episodeId, {
    required int seasonNumber,
    required int episodeNumber,
    required int discNumber,
  }) {
    tvEpisodeDiscAssignments[episodeId] = discNumber;
    tvEpisodeDiscAssignments['$seasonNumber:$episodeNumber'] = discNumber;
  }

  int? discAssignmentForEpisode({
    required String episodeId,
    required int seasonNumber,
    required int episodeNumber,
  }) {
    return tvEpisodeDiscAssignments[episodeId] ??
        tvEpisodeDiscAssignments['$seasonNumber:$episodeNumber'];
  }

  List<TvReleaseMedia> buildFallbackTvReleaseMedia(TvSeries series) {
    final episodeCount = flattenTvEpisodes(series).length;
    final discCount = (initialDiscCount ?? episodeCount).clamp(1, 20).toInt();
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
    return '$seasonPart$episodePart ${episode.title.isEmpty ? 'Episode' : episode.title}';
  }
}
