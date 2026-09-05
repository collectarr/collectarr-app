import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:flutter/material.dart';

class GameEditController {
  GameEditController({
    required String initialPlatforms,
    String initialDevelopers = '',
    String initialSeriesTitle = '',
    String initialPublisher = '',
    String initialReleaseDate = '',
    String initialReleaseYear = '',
    String initialFranchise = '',
    String initialGenres = '',
    String initialAgeRating = '',
    String initialLanguage = '',
    String initialCountry = '',
  })  : platformsController = TextEditingController(text: initialPlatforms),
        developersController = TextEditingController(text: initialDevelopers),
        seriesTitleController = TextEditingController(text: initialSeriesTitle),
        publisherController = TextEditingController(text: initialPublisher),
        releaseDateController = TextEditingController(text: initialReleaseDate),
        releaseYearController = TextEditingController(text: initialReleaseYear),
        franchiseController = TextEditingController(text: initialFranchise),
        genresController = TextEditingController(text: initialGenres),
        ageRatingController = TextEditingController(text: initialAgeRating),
        languageController = TextEditingController(text: initialLanguage),
        countryController = TextEditingController(text: initialCountry);

  final TextEditingController platformsController;
  final TextEditingController developersController;
  final TextEditingController seriesTitleController;
  final TextEditingController publisherController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseYearController;
  final TextEditingController franchiseController;
  final TextEditingController genresController;
  final TextEditingController ageRatingController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  List<String> developerOptions = const [];
  List<String> genreOptions = const [];
  List<String> platformOptions = const [];

  void initialize({
    required CatalogItem item,
    required LibraryEditDraft draft,
  }) {
    final meta = item.kindMetadata is GameCatalogMetadata
        ? (item.kindMetadata as GameCatalogMetadata)
        : null;
    developerOptions = _mergePickListOptions(
      splitPickListValues(developersController.text),
    );
    genreOptions = _mergePickListOptions(
      meta?.genres ?? const <String>[],
    );
    platformOptions = splitPickListValues(platformsController.text);
  }

  void dispose() {
    platformsController.dispose();
    developersController.dispose();
    seriesTitleController.dispose();
    publisherController.dispose();
    releaseDateController.dispose();
    releaseYearController.dispose();
    franchiseController.dispose();
    genresController.dispose();
    ageRatingController.dispose();
    languageController.dispose();
    countryController.dispose();
  }

  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = selection.item.kindMetadata is GameCatalogMetadata
        ? (selection.item.kindMetadata as GameCatalogMetadata)
        : null;
    final platforms = splitPickListValues(platformsController.text);

    final existing = meta?.creators ?? const <Map<String, dynamic>>[];
    final preserved = <Map<String, dynamic>>[];
    for (final entry in existing) {
      final role = entry['role']?.toString().toLowerCase() ?? '';
      if (role.contains('developer')) {
        continue;
      }
      preserved.add(Map<String, dynamic>.from(entry));
    }

    final developerNames = developersController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    final mergedCreators = <Map<String, dynamic>>[
      ...preserved,
      for (final name in developerNames)
        <String, dynamic>{'name': name, 'role': 'Developer'},
    ];

    final updatedPub = emptyToNull(publisherController.text);
    final updatedFranchise = emptyToNull(franchiseController.text);
    final updatedAgeRating = emptyToNull(ageRatingController.text);
    final updatedCountry = emptyToNull(countryController.text);
    final genres = _splitValues(
      genresController.text,
      fallback: meta?.genres ?? const [],
    );
    final languages = _splitValues(
      languageController.text,
      fallback: meta?.languages ?? const [],
    );

    final updatedMetadata = meta?.copyWith(
          platforms: platforms,
          platform: platforms.firstOrNull ?? meta.platform,
          developers:
              developerNames.isNotEmpty ? developerNames : meta.developers,
          creators: mergedCreators.isNotEmpty ? mergedCreators : meta.creators,
          series: emptyToNull(seriesTitleController.text) ?? meta.series,
          publishers: updatedPub != null ? [updatedPub] : meta.publishers,
          franchise: updatedFranchise ?? meta.franchise,
          genres: genres,
          ageRating: updatedAgeRating ?? meta.ageRating,
          languages: languages,
          country: updatedCountry ?? meta.country,
          releaseDate: parseDate(releaseDateController.text),
        ) ??
        selection.item.kindMetadata;

    final updatedItem = selection.item.copyWith(
      kindMetadata: updatedMetadata,
    );

    return LibraryEditSelection(
      scope: selection.scope,
      item: updatedItem,
      personal: selection.personal,
      wishlist: selection.wishlist,
      tracking: selection.tracking,
      customFieldEdits: selection.customFieldEdits,
      itemImageEdits: selection.itemImageEdits,
      submitAction: selection.submitAction,
    );
  }

  List<String> _mergePickListOptions(
    Iterable<String> seed, [
    Iterable<String>? b,
    Iterable<String>? c,
    Iterable<String>? d,
  ]) {
    final merged = <String>[
      ...seed,
      if (b != null) ...b,
      if (c != null) ...c,
      if (d != null) ...d,
    ];
    final seen = <String>{};
    final output = <String>[];
    for (final candidate in merged) {
      final value = candidate.trim();
      if (value.isEmpty) {
        continue;
      }
      final key = value.toLowerCase();
      if (!seen.add(key)) {
        continue;
      }
      output.add(value);
    }
    return output;
  }
}

List<String> _splitValues(String value, {required List<String> fallback}) {
  final values = value
      .split(RegExp(r'[,\r\n]+'))
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toSet()
      .toList();
  return values.isEmpty ? fallback : values;
}
