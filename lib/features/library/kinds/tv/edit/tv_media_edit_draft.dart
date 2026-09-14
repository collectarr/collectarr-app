import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

final class TvMediaEditDraft {
  factory TvMediaEditDraft.fromSeries(TvSeries series) {
    return TvMediaEditDraft(
      original: series,
      titleController: TextEditingController(text: series.title),
      sortTitleController: TextEditingController(text: series.sortTitle),
      descriptionController: TextEditingController(text: series.description),
      networkController: TextEditingController(text: series.network),
      statusController: TextEditingController(text: series.status),
      streamingServiceController: TextEditingController(
        text: _text(series.rawPayload['streaming_service']),
      ),
      originalLanguageController:
          TextEditingController(text: series.originalLanguage),
      contentRatingController: TextEditingController(
        text: _text(series.rawPayload['content_rating']),
      ),
      genresController: TextEditingController(
        text: _strings(series.rawPayload['genres']).join(', '),
      ),
      originalAirDateController: TextEditingController(
        text: _formatDate(series.originalAirDate),
      ),
      endDateController: TextEditingController(
        text: _formatDate(series.endDate),
      ),
    );
  }

  TvMediaEditDraft({
    required this.original,
    required this.titleController,
    required this.sortTitleController,
    required this.descriptionController,
    required this.networkController,
    required this.statusController,
    required this.streamingServiceController,
    required this.originalLanguageController,
    required this.contentRatingController,
    required this.genresController,
    required this.originalAirDateController,
    required this.endDateController,
  });

  final TvSeries original;
  final TextEditingController titleController;
  final TextEditingController sortTitleController;
  final TextEditingController descriptionController;
  final TextEditingController networkController;
  final TextEditingController statusController;
  final TextEditingController streamingServiceController;
  final TextEditingController originalLanguageController;
  final TextEditingController contentRatingController;
  final TextEditingController genresController;
  final TextEditingController originalAirDateController;
  final TextEditingController endDateController;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;
  String get sortTitle => sortTitleController.text;
  set sortTitle(String value) => sortTitleController.text = value;
  String get description => descriptionController.text;
  set description(String value) => descriptionController.text = value;
  String get network => networkController.text;
  set network(String value) => networkController.text = value;
  String get status => statusController.text;
  set status(String value) => statusController.text = value;
  String get streamingService => streamingServiceController.text;
  set streamingService(String value) => streamingServiceController.text = value;
  String get originalLanguage => originalLanguageController.text;
  set originalLanguage(String value) => originalLanguageController.text = value;
  String get contentRating => contentRatingController.text;
  set contentRating(String value) => contentRatingController.text = value;
  List<String> get genres => _split(genresController.text);
  set genres(List<String> value) => genresController.text = value.join(', ');
  DateTime? get originalAirDate =>
      DateTime.tryParse(originalAirDateController.text.trim());
  set originalAirDate(DateTime? value) =>
      originalAirDateController.text = _formatDate(value);
  DateTime? get endDate => DateTime.tryParse(endDateController.text.trim());
  set endDate(DateTime? value) => endDateController.text = _formatDate(value);

  TvSeries toSeries() => TvSeries(
        id: original.id,
        title: title.trim(),
        sortTitle: _emptyToNull(sortTitle),
        description: _emptyToNull(description),
        endDate: endDate,
        episodeCount: original.episodeCount,
        network: _emptyToNull(network),
        originalAirDate: originalAirDate,
        originalLanguage: _emptyToNull(originalLanguage),
        seasonCount: original.seasonCount,
        status: _emptyToNull(status),
        seasons: original.seasons,
        releases: original.releases,
        media: original.media,
        releaseEpisodeMaps: original.releaseEpisodeMaps,
        contributions: original.contributions,
        identifiers: original.identifiers,
        characterAppearances: original.characterAppearances,
        rawPayload: {
          ...original.rawPayload,
          'genres': genres,
          'streaming_service': _emptyToNull(streamingService),
          'content_rating': _emptyToNull(contentRating),
        },
      );

  void dispose() {
    titleController.dispose();
    sortTitleController.dispose();
    descriptionController.dispose();
    networkController.dispose();
    statusController.dispose();
    streamingServiceController.dispose();
    originalLanguageController.dispose();
    contentRatingController.dispose();
    genresController.dispose();
    originalAirDateController.dispose();
    endDateController.dispose();
  }
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String? _text(Object? value) => _emptyToNull(value?.toString() ?? '');

List<String> _strings(Object? value) {
  if (value is! List) return const <String>[];
  return value.whereType<String>().toList(growable: false);
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

String _formatDate(DateTime? value) => value == null
    ? ''
    : '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
