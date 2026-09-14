import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';

final class GameMediaEditDraft {
  GameMediaEditDraft.fromMedia(GameMedia media)
      : original = media,
        titleController = TextEditingController(text: media.title),
        sortTitleController = TextEditingController(text: media.sortTitle),
        descriptionController = TextEditingController(text: media.description),
        subtitleController = TextEditingController(text: media.subtitle),
        publisherController = TextEditingController(text: media.publisher),
        platformsController = TextEditingController(
          text: media.platforms.join(', '),
        ),
        identifiersController = TextEditingController(
          text: media.identifiers.join(', '),
        ),
        companyRolesController = TextEditingController(
          text: media.companyRoles.join(', '),
        ),
        ageRatingsController = TextEditingController(
          text: media.ageRatings.join(', '),
        ),
        genresController = TextEditingController(text: media.genres.join(', ')),
        searchAliasesController = TextEditingController(
          text: media.searchAliases.join(', '),
        ),
        originalLanguageController =
            TextEditingController(text: media.originalLanguage),
        releaseDateController = TextEditingController(
          text: _formatDate(media.releaseDate),
        );

  final GameMedia original;
  final TextEditingController titleController;
  final TextEditingController sortTitleController;
  final TextEditingController descriptionController;
  final TextEditingController subtitleController;
  final TextEditingController publisherController;
  final TextEditingController platformsController;
  final TextEditingController identifiersController;
  final TextEditingController companyRolesController;
  final TextEditingController ageRatingsController;
  final TextEditingController genresController;
  final TextEditingController searchAliasesController;
  final TextEditingController originalLanguageController;
  final TextEditingController releaseDateController;

  String get title => titleController.text;
  set title(String value) => titleController.text = value;
  String get sortTitle => sortTitleController.text;
  set sortTitle(String value) => sortTitleController.text = value;
  String get description => descriptionController.text;
  set description(String value) => descriptionController.text = value;
  String get subtitle => subtitleController.text;
  set subtitle(String value) => subtitleController.text = value;
  String? get publisher => _emptyToNull(publisherController.text);
  set publisher(String? value) => publisherController.text = value ?? '';
  List<String> get platforms => _split(platformsController.text);
  set platforms(List<String> value) =>
      platformsController.text = value.join(', ');
  List<String> get identifiers => _split(identifiersController.text);
  set identifiers(List<String> value) =>
      identifiersController.text = value.join(', ');
  List<String> get companyRoles => _split(companyRolesController.text);
  set companyRoles(List<String> value) =>
      companyRolesController.text = value.join(', ');
  List<String> get ageRatings => _split(ageRatingsController.text);
  set ageRatings(List<String> value) =>
      ageRatingsController.text = value.join(', ');
  List<String> get genres => _split(genresController.text);
  set genres(List<String> value) => genresController.text = value.join(', ');
  List<String> get searchAliases => _split(searchAliasesController.text);
  set searchAliases(List<String> value) =>
      searchAliasesController.text = value.join(', ');
  String? get originalLanguage => _emptyToNull(originalLanguageController.text);
  set originalLanguage(String? value) =>
      originalLanguageController.text = value ?? '';
  DateTime? get releaseDate => DateTime.tryParse(releaseDateController.text);
  set releaseDate(DateTime? value) =>
      releaseDateController.text = _formatDate(value);

  GameMedia toMedia() => GameMedia(
        id: original.id,
        title: title.trim(),
        sortTitle: _emptyToNull(sortTitle),
        description: _emptyToNull(description),
        releaseDate: releaseDate,
        originalLanguage: originalLanguage,
        publisher: publisher,
        subtitle: _emptyToNull(subtitle),
        platforms: platforms,
        identifiers: identifiers,
        companyRoles: companyRoles,
        ageRatings: ageRatings,
        genres: genres,
        searchAliases: searchAliases,
        releases: original.releases,
        rawPayload: {
          ...original.rawPayload,
          'platforms': platforms,
          'identifiers': identifiers,
          'company_roles': companyRoles,
          'age_ratings': ageRatings,
          'genres': genres,
          'search_aliases': searchAliases,
        },
      );

  void dispose() {
    titleController.dispose();
    sortTitleController.dispose();
    descriptionController.dispose();
    subtitleController.dispose();
    publisherController.dispose();
    platformsController.dispose();
    identifiersController.dispose();
    companyRolesController.dispose();
    ageRatingsController.dispose();
    genresController.dispose();
    searchAliasesController.dispose();
    originalLanguageController.dispose();
    releaseDateController.dispose();
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

String _formatDate(DateTime? value) => value == null
    ? ''
    : '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
