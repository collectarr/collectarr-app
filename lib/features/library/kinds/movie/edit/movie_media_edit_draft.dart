import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';

final class MovieMediaEditDraft {
  factory MovieMediaEditDraft.fromMedia(MovieMedia media) {
    return MovieMediaEditDraft(
      original: media,
      titleController: TextEditingController(text: media.title),
      sortTitleController: TextEditingController(text: media.sortTitle),
      descriptionController: TextEditingController(text: media.description),
      originalLanguageController:
          TextEditingController(text: media.originalLanguage),
      ageRatingController: TextEditingController(text: media.ageRating),
      audienceRatingController:
          TextEditingController(text: media.audienceRating),
      runtimeMinutesController:
          TextEditingController(text: media.runtimeMinutes?.toString()),
      subtitleController: TextEditingController(text: media.subtitle),
      releaseDateController: TextEditingController(
        text: media.releaseDate == null ? '' : _formatDate(media.releaseDate!),
      ),
      genresController: TextEditingController(
        text: _strings(media.rawPayload['genres']).join(', '),
      ),
    );
  }

  MovieMediaEditDraft({
    required this.original,
    required this.titleController,
    required this.sortTitleController,
    required this.descriptionController,
    required this.originalLanguageController,
    required this.ageRatingController,
    required this.audienceRatingController,
    required this.runtimeMinutesController,
    required this.subtitleController,
    required this.releaseDateController,
    required this.genresController,
  });

  final MovieMedia original;
  final TextEditingController titleController;
  final TextEditingController sortTitleController;
  final TextEditingController descriptionController;
  final TextEditingController originalLanguageController;
  final TextEditingController ageRatingController;
  final TextEditingController audienceRatingController;
  final TextEditingController runtimeMinutesController;
  final TextEditingController subtitleController;
  final TextEditingController releaseDateController;
  final TextEditingController genresController;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;
  String get sortTitle => sortTitleController.text;
  set sortTitle(String value) => sortTitleController.text = value;
  String get description => descriptionController.text;
  set description(String value) => descriptionController.text = value;
  String get originalLanguage => originalLanguageController.text;
  set originalLanguage(String value) => originalLanguageController.text = value;
  String get ageRating => ageRatingController.text;
  set ageRating(String value) => ageRatingController.text = value;
  String get audienceRating => audienceRatingController.text;
  set audienceRating(String value) => audienceRatingController.text = value;
  int? get runtimeMinutes => int.tryParse(runtimeMinutesController.text);
  set runtimeMinutes(int? value) =>
      runtimeMinutesController.text = value?.toString() ?? '';
  String get subtitle => subtitleController.text;
  set subtitle(String value) => subtitleController.text = value;
  DateTime? get releaseDate => DateTime.tryParse(releaseDateController.text);
  set releaseDate(DateTime? value) =>
      releaseDateController.text = value == null ? '' : _formatDate(value);
  List<String> get genres => _split(genresController.text);
  set genres(List<String> value) => genresController.text = value.join(', ');

  MovieMedia toMedia() {
    return MovieMedia(
      id: original.id,
      title: title.trim(),
      ageRating: _emptyToNull(ageRating),
      audienceRating: _emptyToNull(audienceRating),
      characterAppearances: original.characterAppearances,
      contributions: original.contributions,
      description: _emptyToNull(description),
      externalLinks: original.externalLinks,
      identifiers: original.identifiers,
      originalLanguage: _emptyToNull(originalLanguage),
      releaseDate: releaseDate,
      releases: original.releases,
      runtimeMinutes: runtimeMinutes,
      sortTitle: _emptyToNull(sortTitle),
      subtitle: _emptyToNull(subtitle),
      trailerUrls: original.trailerUrls,
      rawPayload: {
        ...original.rawPayload,
        'genres': genres,
      },
    );
  }

  void dispose() {
    titleController.dispose();
    sortTitleController.dispose();
    descriptionController.dispose();
    originalLanguageController.dispose();
    ageRatingController.dispose();
    audienceRatingController.dispose();
    runtimeMinutesController.dispose();
    subtitleController.dispose();
    releaseDateController.dispose();
    genresController.dispose();
  }
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

List<String> _strings(Object? value) {
  if (value is! List) return const <String>[];
  return value.whereType<String>().toList(growable: false);
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
