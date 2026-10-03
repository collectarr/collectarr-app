import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
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
    required CatalogItemDto item,
    required LibraryEditShellState draft,
  }) {
    final meta = GameCatalogMetadata.fromJson(item.payload);
    developerOptions = _mergePickListOptions(
      splitPickListValues(developersController.text),
    );
    genreOptions = _mergePickListOptions(
      meta.genres,
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
    final meta = selection.kindItem.kindCapability.mapTransport(
      (transport) => GameCatalogMetadata.fromJson(transport.kindData),
    );
    final platforms = splitPickListValues(platformsController.text);

    final existing = meta.creators;
    final preserved = <GameCatalogPersonCredit>[];
    for (final entry in existing) {
      final role = entry.role?.toLowerCase() ?? '';
      if (role.contains('developer')) {
        continue;
      }
      preserved.add(entry);
    }

    final developerNames = developersController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    final mergedCreators = <GameCatalogPersonCredit>[
      ...preserved,
      for (final name in developerNames)
        GameCatalogPersonCredit(name: name, role: 'Developer'),
    ];

    final updatedPub = emptyToNull(publisherController.text);
    final updatedFranchise = emptyToNull(franchiseController.text);
    final updatedAgeRating = emptyToNull(ageRatingController.text);
    final updatedCountry = emptyToNull(countryController.text);
    final genres = _splitValues(
      genresController.text,
      fallback: meta.genres,
    );
    final languages = _splitValues(
      languageController.text,
      fallback: meta.languages,
    );

    final updatedMetadata = meta.copyWith(
      platforms: platforms,
      developers: developerNames.isNotEmpty ? developerNames : meta.developers,
      creators: mergedCreators.isNotEmpty ? mergedCreators : meta.creators,
      seriesTitle: emptyToNull(seriesTitleController.text) ?? meta.seriesTitle,
      publisher: updatedPub ?? meta.publisher,
      franchise: updatedFranchise ?? meta.franchise,
      genres: genres,
      ageRating: updatedAgeRating ?? meta.ageRating,
      languages: languages,
      country: updatedCountry ?? meta.country,
      releaseDateParts: parseDate(releaseDateController.text) == null
          ? meta.releaseDateParts
          : PartialDate.fromDateTime(parseDate(releaseDateController.text)!),
    );

    final updatedItem = selection.kindItem.kindCapability.mapTransport(
      (transport) => CatalogSearchCandidate.fromItem(
        transport.withKindData(updatedMetadata),
      ),
    );

    return LibraryEditSelection(
      scope: selection.scope,
      kindItem: updatedItem,
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
