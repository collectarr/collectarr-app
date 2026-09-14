import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';

final class AnimeMediaEditDraft {
  factory AnimeMediaEditDraft.fromMedia(AnimeMedia media) {
    return AnimeMediaEditDraft(
      original: media,
      titleController: TextEditingController(text: media.title),
      sortTitleController: TextEditingController(text: media.sortTitle),
      descriptionController: TextEditingController(text: media.description),
      animeTypeController: TextEditingController(text: media.animeType),
      statusController: TextEditingController(text: media.status),
      originalLanguageController:
          TextEditingController(text: media.originalLanguage),
      genresController: TextEditingController(
        text: _strings(media.rawPayload['genres']).join(', '),
      ),
      studiosController: TextEditingController(
        text: _strings(media.rawPayload['studios']).join(', '),
      ),
      producersController: TextEditingController(
        text: _strings(media.rawPayload['producers']).join(', '),
      ),
      licensorsController: TextEditingController(
        text: _strings(media.rawPayload['licensors']).join(', '),
      ),
      themesController: TextEditingController(
        text: _strings(media.rawPayload['themes']).join(', '),
      ),
      seasonController: TextEditingController(
        text: _text(media.rawPayload['season']),
      ),
      seasonYearController: TextEditingController(
        text: _numberText(media.rawPayload['season_year']),
      ),
      sourceMaterialController: TextEditingController(
        text: _text(media.rawPayload['source_material']),
      ),
      episodeCountController:
          TextEditingController(text: media.episodeCount?.toString()),
      episodeRuntimeController: TextEditingController(
        text: _numberText(media.rawPayload['episode_runtime_minutes']),
      ),
      originalAirDateController: TextEditingController(
        text: _formatDate(media.originalAirDate),
      ),
      endDateController:
          TextEditingController(text: _formatDate(media.endDate)),
      coverImageUrlController: TextEditingController(text: media.coverImageUrl),
    );
  }

  AnimeMediaEditDraft({
    required this.original,
    required this.titleController,
    required this.sortTitleController,
    required this.descriptionController,
    required this.animeTypeController,
    required this.statusController,
    required this.originalLanguageController,
    required this.genresController,
    required this.studiosController,
    required this.producersController,
    required this.licensorsController,
    required this.themesController,
    required this.seasonController,
    required this.seasonYearController,
    required this.sourceMaterialController,
    required this.episodeCountController,
    required this.episodeRuntimeController,
    required this.originalAirDateController,
    required this.endDateController,
    required this.coverImageUrlController,
  });

  final AnimeMedia original;
  final TextEditingController titleController;
  final TextEditingController sortTitleController;
  final TextEditingController descriptionController;
  final TextEditingController animeTypeController;
  final TextEditingController statusController;
  final TextEditingController originalLanguageController;
  final TextEditingController genresController;
  final TextEditingController studiosController;
  final TextEditingController producersController;
  final TextEditingController licensorsController;
  final TextEditingController themesController;
  final TextEditingController seasonController;
  final TextEditingController seasonYearController;
  final TextEditingController sourceMaterialController;
  final TextEditingController episodeCountController;
  final TextEditingController episodeRuntimeController;
  final TextEditingController originalAirDateController;
  final TextEditingController endDateController;
  final TextEditingController coverImageUrlController;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;
  String get sortTitle => sortTitleController.text;
  set sortTitle(String value) => sortTitleController.text = value;
  String get description => descriptionController.text;
  set description(String value) => descriptionController.text = value;
  String? get animeType => _emptyToNull(animeTypeController.text);
  set animeType(String? value) => animeTypeController.text = value ?? '';
  String? get status => _emptyToNull(statusController.text);
  set status(String? value) => statusController.text = value ?? '';
  String? get originalLanguage => _emptyToNull(originalLanguageController.text);
  set originalLanguage(String? value) =>
      originalLanguageController.text = value ?? '';
  List<String> get genres => _split(genresController.text);
  set genres(List<String> value) => genresController.text = value.join(', ');
  List<String> get studios => _split(studiosController.text);
  set studios(List<String> value) => studiosController.text = value.join(', ');
  List<String> get producers => _split(producersController.text);
  set producers(List<String> value) =>
      producersController.text = value.join(', ');
  List<String> get licensors => _split(licensorsController.text);
  set licensors(List<String> value) =>
      licensorsController.text = value.join(', ');
  List<String> get themes => _split(themesController.text);
  set themes(List<String> value) => themesController.text = value.join(', ');
  String? get season => _emptyToNull(seasonController.text);
  set season(String? value) => seasonController.text = value ?? '';
  int? get seasonYear => int.tryParse(seasonYearController.text.trim());
  set seasonYear(int? value) =>
      seasonYearController.text = value?.toString() ?? '';
  String? get sourceMaterial => _emptyToNull(sourceMaterialController.text);
  set sourceMaterial(String? value) =>
      sourceMaterialController.text = value ?? '';
  int? get episodeCount => int.tryParse(episodeCountController.text.trim());
  set episodeCount(int? value) =>
      episodeCountController.text = value?.toString() ?? '';
  int? get episodeRuntimeMinutes =>
      int.tryParse(episodeRuntimeController.text.trim());
  set episodeRuntimeMinutes(int? value) =>
      episodeRuntimeController.text = value?.toString() ?? '';
  DateTime? get originalAirDate => _date(originalAirDateController.text);
  set originalAirDate(DateTime? value) =>
      originalAirDateController.text = _formatDate(value);
  DateTime? get endDate => _date(endDateController.text);
  set endDate(DateTime? value) => endDateController.text = _formatDate(value);
  String? get coverImageUrl => _emptyToNull(coverImageUrlController.text);
  set coverImageUrl(String? value) =>
      coverImageUrlController.text = value ?? '';

  AnimeMedia toMedia() => AnimeMedia(
        id: original.id,
        title: title.trim(),
        animeType: animeType,
        characterAppearances: original.characterAppearances,
        contributions: original.contributions,
        description: _emptyToNull(description),
        endDate: endDate,
        episodeCount: episodeCount,
        episodes: original.episodes,
        identifiers: original.identifiers,
        originalAirDate: originalAirDate,
        originalLanguage: originalLanguage,
        sortTitle: _emptyToNull(sortTitle),
        status: status,
        releases: original.releases,
        rawPayload: {
          ...original.rawPayload,
          'genres': genres,
          'studios': studios,
          'producers': producers,
          'licensors': licensors,
          'themes': themes,
          'season': season,
          'season_year': seasonYear,
          'source_material': sourceMaterial,
          'episode_runtime_minutes': episodeRuntimeMinutes,
          'cover_image_url': coverImageUrl,
        },
      );

  void dispose() {
    titleController.dispose();
    sortTitleController.dispose();
    descriptionController.dispose();
    animeTypeController.dispose();
    statusController.dispose();
    originalLanguageController.dispose();
    genresController.dispose();
    studiosController.dispose();
    producersController.dispose();
    licensorsController.dispose();
    themesController.dispose();
    seasonController.dispose();
    seasonYearController.dispose();
    sourceMaterialController.dispose();
    episodeCountController.dispose();
    episodeRuntimeController.dispose();
    originalAirDateController.dispose();
    endDateController.dispose();
    coverImageUrlController.dispose();
  }
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String? _text(Object? value) => _emptyToNull(value?.toString() ?? '');

String? _numberText(Object? value) {
  if (value is num) return value.toInt().toString();
  return _text(value);
}

DateTime? _date(String value) => DateTime.tryParse(value.trim());

List<String> _strings(Object? value) {
  if (value is! Iterable) return const <String>[];
  return value
      .map((entry) => entry.toString().trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
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
