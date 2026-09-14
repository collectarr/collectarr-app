import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';

final class MangaMediaEditDraft {
  MangaMediaEditDraft.fromMedia(MangaMedia media)
      : original = media,
        titleController = TextEditingController(text: media.title),
        sortTitleController = TextEditingController(text: media.sortTitle),
        descriptionController = TextEditingController(text: media.description),
        subtitleController = TextEditingController(text: media.subtitle),
        originalLanguageController =
            TextEditingController(text: media.originalLanguage),
        firstPublicationDateController = TextEditingController(
          text: _formatDate(media.firstPublicationDate),
        ),
        originalPublicationDateController = TextEditingController(
          text: _formatDate(media.originalPublicationDate),
        ),
        statusController = TextEditingController(text: media.status),
        genresController = TextEditingController(
          text: _strings(media.rawPayload['genres']).join(', '),
        ),
        searchAliasesController = TextEditingController(
          text: media.rawPayload['search_aliases'] is List
              ? _strings(media.rawPayload['search_aliases']).join(', ')
              : '',
        );

  final MangaMedia original;
  final TextEditingController titleController;
  final TextEditingController sortTitleController;
  final TextEditingController descriptionController;
  final TextEditingController subtitleController;
  final TextEditingController originalLanguageController;
  final TextEditingController firstPublicationDateController;
  final TextEditingController originalPublicationDateController;
  final TextEditingController statusController;
  final TextEditingController genresController;
  final TextEditingController searchAliasesController;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;
  String get sortTitle => sortTitleController.text;
  set sortTitle(String value) => sortTitleController.text = value;
  String get description => descriptionController.text;
  set description(String value) => descriptionController.text = value;
  String get subtitle => subtitleController.text;
  set subtitle(String value) => subtitleController.text = value;
  String get originalLanguage => originalLanguageController.text;
  set originalLanguage(String value) => originalLanguageController.text = value;
  DateTime? get firstPublicationDate =>
      DateTime.tryParse(firstPublicationDateController.text.trim());
  set firstPublicationDate(DateTime? value) =>
      firstPublicationDateController.text = _formatDate(value);
  DateTime? get originalPublicationDate =>
      DateTime.tryParse(originalPublicationDateController.text.trim());
  set originalPublicationDate(DateTime? value) =>
      originalPublicationDateController.text = _formatDate(value);
  String? get status => _emptyToNull(statusController.text);
  set status(String? value) => statusController.text = value ?? '';
  List<String> get genres => _split(genresController.text);
  set genres(List<String> value) => genresController.text = value.join(', ');
  List<String> get searchAliases => _split(searchAliasesController.text);
  set searchAliases(List<String> value) =>
      searchAliasesController.text = value.join(', ');

  MangaMedia toMedia() => MangaMedia(
        id: original.id,
        title: title.trim(),
        sortTitle: _emptyToNull(sortTitle),
        description: _emptyToNull(description),
        firstPublicationDate: firstPublicationDate,
        originalLanguage: _emptyToNull(originalLanguage),
        originalPublicationDate: originalPublicationDate,
        status: status,
        subtitle: _emptyToNull(subtitle),
        chapters: original.chapters,
        characterAppearances: original.characterAppearances,
        contributions: original.contributions,
        identifiers: original.identifiers,
        series: original.series,
        rawPayload: {
          ...original.rawPayload,
          'genres': genres,
          'search_aliases': searchAliases,
        },
      );

  void dispose() {
    titleController.dispose();
    sortTitleController.dispose();
    descriptionController.dispose();
    subtitleController.dispose();
    originalLanguageController.dispose();
    firstPublicationDateController.dispose();
    originalPublicationDateController.dispose();
    statusController.dispose();
    genresController.dispose();
    searchAliasesController.dispose();
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
  if (value is! Iterable) return const <String>[];
  return value
      .map((entry) => entry.toString().trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
}

String _formatDate(DateTime? value) => value == null
    ? ''
    : '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
