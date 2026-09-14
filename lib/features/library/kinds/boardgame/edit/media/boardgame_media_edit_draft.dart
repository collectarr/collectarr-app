import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';

final class BoardGameMediaEditDraft {
  BoardGameMediaEditDraft.fromMedia(BoardGameMedia media)
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
        contributorsController = TextEditingController(
          text: media.contributors.join(', '),
        ),
        mechanicsController = TextEditingController(
          text: media.mechanics.join(', '),
        ),
        categoriesController = TextEditingController(
          text: media.categories.join(', '),
        ),
        familiesController = TextEditingController(
          text: media.families.join(', '),
        ),
        expansionsController = TextEditingController(
          text: media.expansions.join(', '),
        ),
        rankingsController = TextEditingController(
          text: media.rankings.join(', '),
        ),
        searchAliasesController = TextEditingController(
          text: media.searchAliases.join(', '),
        ),
        originalLanguageController =
            TextEditingController(text: media.originalLanguage),
        releaseDateController = TextEditingController(
          text: _formatDate(media.releaseDate),
        );

  final BoardGameMedia original;
  final TextEditingController titleController;
  final TextEditingController sortTitleController;
  final TextEditingController descriptionController;
  final TextEditingController subtitleController;
  final TextEditingController publisherController;
  final TextEditingController platformsController;
  final TextEditingController identifiersController;
  final TextEditingController contributorsController;
  final TextEditingController mechanicsController;
  final TextEditingController categoriesController;
  final TextEditingController familiesController;
  final TextEditingController expansionsController;
  final TextEditingController rankingsController;
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
  List<String> get contributors => _split(contributorsController.text);
  set contributors(List<String> value) =>
      contributorsController.text = value.join(', ');
  List<String> get mechanics => _split(mechanicsController.text);
  set mechanics(List<String> value) =>
      mechanicsController.text = value.join(', ');
  List<String> get categories => _split(categoriesController.text);
  set categories(List<String> value) =>
      categoriesController.text = value.join(', ');
  List<String> get families => _split(familiesController.text);
  set families(List<String> value) =>
      familiesController.text = value.join(', ');
  List<String> get expansions => _split(expansionsController.text);
  set expansions(List<String> value) =>
      expansionsController.text = value.join(', ');
  List<String> get rankings => _split(rankingsController.text);
  set rankings(List<String> value) =>
      rankingsController.text = value.join(', ');
  List<String> get searchAliases => _split(searchAliasesController.text);
  set searchAliases(List<String> value) =>
      searchAliasesController.text = value.join(', ');
  String? get originalLanguage => _emptyToNull(originalLanguageController.text);
  set originalLanguage(String? value) =>
      originalLanguageController.text = value ?? '';
  DateTime? get releaseDate => DateTime.tryParse(releaseDateController.text);
  set releaseDate(DateTime? value) =>
      releaseDateController.text = _formatDate(value);

  BoardGameMedia toMedia() => BoardGameMedia(
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
        contributors: contributors,
        mechanics: mechanics,
        categories: categories,
        families: families,
        expansions: expansions,
        rankings: rankings,
        searchAliases: searchAliases,
        editions: original.editions,
        rawPayload: {
          ...original.rawPayload,
          'platforms': platforms,
          'identifiers': identifiers,
          'contributors': contributors,
          'mechanics': mechanics,
          'categories': categories,
          'families': families,
          'expansions': expansions,
          'rankings': rankings,
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
    contributorsController.dispose();
    mechanicsController.dispose();
    categoriesController.dispose();
    familiesController.dispose();
    expansionsController.dispose();
    rankingsController.dispose();
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
