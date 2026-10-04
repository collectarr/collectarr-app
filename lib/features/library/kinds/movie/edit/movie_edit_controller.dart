import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_credit_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:flutter/material.dart';

class MovieEditController {
  MovieEditController({
    this.initialRuntime = '',
    this.initialAgeRating = '',
    this.initialAudienceRating = '',
    this.initialGenres = '',
    this.initialEditionTitle = '',
    this.initialVariant = '',
    this.initialBarcode = '',
    this.initialPhysicalFormatLabel = '',
    this.initialPhysicalFormatId,
    this.initialPublisher = '',
    this.initialCountry = '',
    this.initialLanguage = '',
    this.initialReleaseDate = '',
    this.initialReleaseYear = '',
    this.initialCreators = const <MovieCreditInput>[],
    this.initialCharacters = const <MovieCharacter>[],
    this.initialTrailerLinks = const <TrailerLinkDto>[],
  })  : runtimeController = TextEditingController(text: initialRuntime),
        ageRatingController = TextEditingController(text: initialAgeRating),
        audienceRatingController =
            TextEditingController(text: initialAudienceRating),
        genresEditController = TextEditingController(text: initialGenres),
        editionTitleController =
            TextEditingController(text: initialEditionTitle),
        variantController = TextEditingController(text: initialVariant),
        barcodeController = TextEditingController(text: initialBarcode),
        physicalFormatLabelController =
            TextEditingController(text: initialPhysicalFormatLabel),
        physicalFormatId = initialPhysicalFormatId,
        publisherController = TextEditingController(text: initialPublisher),
        countryController = TextEditingController(text: initialCountry),
        languageController = TextEditingController(text: initialLanguage),
        releaseDateController = TextEditingController(text: initialReleaseDate),
        releaseYearController = TextEditingController(text: initialReleaseYear);

  final String initialRuntime;
  final String initialAgeRating;
  final String initialAudienceRating;
  final String initialGenres;
  final String initialEditionTitle;
  final String initialVariant;
  final String initialBarcode;
  final String initialPhysicalFormatLabel;
  final String? initialPhysicalFormatId;
  final String initialPublisher;
  final String initialCountry;
  final String initialLanguage;
  final String initialReleaseDate;
  final String initialReleaseYear;
  final List<MovieCreditInput> initialCreators;
  final List<MovieCharacter> initialCharacters;
  final List<TrailerLinkDto> initialTrailerLinks;

  final TextEditingController runtimeController;
  final TextEditingController ageRatingController;
  final TextEditingController audienceRatingController;
  final TextEditingController genresEditController;

  final TextEditingController editionTitleController;
  final TextEditingController variantController;
  final TextEditingController barcodeController;
  final TextEditingController physicalFormatLabelController;
  String? physicalFormatId;
  final TextEditingController publisherController;
  final TextEditingController countryController;
  final TextEditingController languageController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseYearController;

  final List<EditableMovieCredit> castCredits = [];
  final List<EditableMovieCredit> crewCredits = [];
  final List<MovieCharacter> characters = [];

  void initializeMovieEditors() {
    final creators = initialCreators;
    castCredits.addAll(
      splitMovieCredits(creators, kind: MovieCreditKind.cast),
    );
    crewCredits.addAll(
      splitMovieCredits(creators, kind: MovieCreditKind.crew),
    );
  }

  void dispose() {
    runtimeController.dispose();
    ageRatingController.dispose();
    audienceRatingController.dispose();
    genresEditController.dispose();
    editionTitleController.dispose();
    variantController.dispose();
    barcodeController.dispose();
    physicalFormatLabelController.dispose();
    publisherController.dispose();
    countryController.dispose();
    languageController.dispose();
    releaseDateController.dispose();
    releaseYearController.dispose();
    for (final credit in castCredits) {
      credit.dispose();
    }
    for (final credit in crewCredits) {
      credit.dispose();
    }
  }

  List<TrailerLinkDto>? buildUpdatedTrailerUrls(
    List<TrailerLinkDto> existing, {
    required bool preserveManualLinks,
  }) {
    final preservedTrailers = existing
        .where(
          (link) =>
              link.isTrailerLink && (link.isAutomatic || preserveManualLinks),
        )
        .toList(growable: false);
    final providerExternalLinks = existing
        .where(
          (link) =>
              link.isExternalLink && (link.isAutomatic || preserveManualLinks),
        )
        .toList(growable: false);
    final merged = <TrailerLinkDto>[
      ...preservedTrailers,
      ...providerExternalLinks,
    ];
    return merged.isEmpty ? null : List<TrailerLinkDto>.unmodifiable(merged);
  }
}
