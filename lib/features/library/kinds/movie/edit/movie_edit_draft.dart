import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft_contract.dart';

enum MovieCanonicalEditField {
  title,
  displayTitle,
  sortTitle,
  originalTitle,
  localizedTitle,
  searchAliases,
  synopsis,
  coverImage,
  thumbnailImage
}

class MovieEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements MovieEditDraftContract {
  MovieEditDraft({
    this.libraryEntry,
    required this.featuresController,
    required this.boxSetNameController,
    required this.regionController,
    required this.packagingController,
    required this.distributorController,
    required this.screenRatioController,
    required this.audioTracksController,
    required this.subtitlesController,
    required this.layersController,
    required this.colorController,
    required this.nrDiscsController,
    required this.hdrFormats,
    required this.movieEdit,
  });

  final MovieLibraryEntry? libraryEntry;

  @override
  final TextEditingController featuresController;
  @override
  final TextEditingController boxSetNameController;
  @override
  final TextEditingController regionController;
  @override
  final TextEditingController packagingController;
  @override
  final TextEditingController distributorController;
  @override
  final TextEditingController screenRatioController;
  @override
  final TextEditingController audioTracksController;
  @override
  final TextEditingController subtitlesController;
  @override
  final TextEditingController layersController;
  @override
  final TextEditingController colorController;
  @override
  final TextEditingController nrDiscsController;

  @override
  List<String> hdrFormats;
  @override
  final MovieEditController movieEdit;

  @override
  JsonEncodable toDetailsDraft() => MovieEntryDetailsDraft(
        features: emptyToNull(featuresController.text),
        hdrFormats: hdrFormats,
        boxSetName: emptyToNull(boxSetNameController.text),
        region: emptyToNull(regionController.text),
        packaging: emptyToNull(packagingController.text),
        distributor: emptyToNull(distributorController.text),
      );

  @override
  void initializePersonalState(PersonalStateDraft personal) {
    final item = libraryEntry;
    if (item == null) return;
    personal.ownerLabelController.text = item.personal.ownerLabel ?? '';
    personal.conditionController.text = item.personal.condition ?? '';
    personal.gradeController.text = item.personal.grade ?? '';
    personal.purchaseDateController.text = item.personal.purchaseDate == null
        ? ''
        : formatDate(item.personal.purchaseDate!);
    personal.priceController.text = item.personal.pricePaidCents == null
        ? ''
        : (item.personal.pricePaidCents! / 100).toStringAsFixed(2);
    personal.currencyController.text = item.personal.currency ?? '';
    personal.indexNumberController.text =
        item.personal.indexNumber?.toString() ?? '';
    personal.notesController.text = item.personal.personalNotes ?? '';
    personal.tagsController.text = item.personal.tags ?? '';
    personal.sellPriceController.text = item.personal.sellPriceCents == null
        ? ''
        : (item.personal.sellPriceCents! / 100).toStringAsFixed(2);
    personal.soldToController.text = item.personal.soldTo ?? '';
    personal.purchaseStoreController.text = item.personal.purchaseStore ?? '';
    personal.marketValueController.text = item.personal.marketValueCents == null
        ? ''
        : (item.personal.marketValueCents! / 100).toStringAsFixed(2);
    personal.selectedLocationId = item.personal.locationId;
    personal.soldAt = item.personal.soldAt;
    personal.collectionStatus = item.personal.collectionStatus;
  }

  @override
  MovieLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required PersonalStateDraft personal,
  }) {
    return MovieLibraryEntryUpdatePayload(
      isDigital: const Patch.unchanged(),
      marketValueCents: const Patch.unchanged(),
      indexNumber: const Patch.unchanged(),
      condition: personal.conditionController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.conditionController.text.trim()),
      grade: personal.gradeController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.gradeController.text.trim()),
      purchaseDate: personal.purchaseDateController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseDate(personal.purchaseDateController.text)),
      pricePaidCents: personal.priceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(personal.priceController.text)),
      currency: personal.currencyController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.currencyController.text.trim()),
      personalNotes: personal.notesController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.notesController.text.trim()),
      locationId: personal.selectedLocationId != null
          ? Patch.set(personal.selectedLocationId)
          : const Patch.clear(),
      purchaseStore: personal.purchaseStoreController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.purchaseStoreController.text.trim()),
      collectionStatus: personal.collectionStatus != null
          ? Patch.set(personal.collectionStatus)
          : const Patch.clear(),
      tags: personal.tagsController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.tagsController.text.trim()),
      soldAt: personal.soldAt != null
          ? Patch.set(personal.soldAt)
          : const Patch.clear(),
      sellPriceCents: personal.sellPriceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(personal.sellPriceController.text)),
      soldTo: personal.soldToController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.soldToController.text.trim()),
      details: Patch.set(toDetailsDraft() as MovieEntryDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) {
    final aliases = fields
        .controller(MovieCanonicalEditField.searchAliases)
        .text
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    return selection.copyWith(
      kindItem: CatalogSearchCandidate.fromItem(selection
          .kindItem.kindCapability
          .mapTransport((transport) => transport.copyWith(
                title: fields
                    .controller(MovieCanonicalEditField.title)
                    .text
                    .trim(),
                displayTitle: emptyToNull(fields
                    .controller(MovieCanonicalEditField.displayTitle)
                    .text),
                sortKey: emptyToNull(
                    fields.controller(MovieCanonicalEditField.sortTitle).text),
                originalTitle: emptyToNull(fields
                    .controller(MovieCanonicalEditField.originalTitle)
                    .text),
                localizedTitle: emptyToNull(fields
                    .controller(MovieCanonicalEditField.localizedTitle)
                    .text),
                searchAliases: aliases.isEmpty ? null : aliases,
                synopsis: emptyToNull(
                    fields.controller(MovieCanonicalEditField.synopsis).text),
                coverImageUrl: emptyToNull(
                    fields.controller(MovieCanonicalEditField.coverImage).text),
                thumbnailImageUrl: emptyToNull(fields
                    .controller(MovieCanonicalEditField.thumbnailImage)
                    .text),
              ))),
    );
  }

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) {
    final metadata = item.movieCatalogFields;
    fields.create(MovieCanonicalEditField.title, initialValue: metadata.title);
    fields.create(MovieCanonicalEditField.displayTitle,
        initialValue: metadata.displayTitle ?? '');
    fields.create(MovieCanonicalEditField.sortTitle,
        initialValue: metadata.sortKey ?? '');
    fields.create(MovieCanonicalEditField.originalTitle,
        initialValue: metadata.originalTitle ?? '');
    fields.create(MovieCanonicalEditField.localizedTitle,
        initialValue: metadata.localizedTitle ?? '');
    fields.create(MovieCanonicalEditField.searchAliases,
        initialValue: metadata.searchAliases.join(', '));
    fields.create(MovieCanonicalEditField.synopsis,
        initialValue: metadata.synopsis ?? '');
    fields.create(MovieCanonicalEditField.coverImage,
        initialValue: metadata.coverImageUrl ?? '');
    fields.create(MovieCanonicalEditField.thumbnailImage,
        initialValue: metadata.thumbnailImageUrl ?? '');
    return LibraryEditFormSchema(
      fields: [
        LibraryEditFormFieldSpec(
          id: MovieCanonicalEditField.title,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MovieCanonicalEditField.title),
          label: 'Title',
          required: true,
        ),
        LibraryEditFormFieldSpec(
          id: MovieCanonicalEditField.sortTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MovieCanonicalEditField.sortTitle),
          label: 'Sort title',
        ),
        LibraryEditFormFieldSpec(
          id: MovieCanonicalEditField.originalTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MovieCanonicalEditField.originalTitle),
          label: 'Original title',
        ),
        LibraryEditFormFieldSpec(
          id: MovieCanonicalEditField.localizedTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MovieCanonicalEditField.localizedTitle),
          label: 'Localized title',
        ),
        LibraryEditFormFieldSpec(
          id: MovieCanonicalEditField.displayTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MovieCanonicalEditField.displayTitle),
          label: 'Display title',
        ),
        LibraryEditFormFieldSpec(
          id: MovieCanonicalEditField.searchAliases,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MovieCanonicalEditField.searchAliases),
          label: 'Search aliases',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: MovieCanonicalEditField.thumbnailImage,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MovieCanonicalEditField.thumbnailImage),
          label: 'Thumbnail image URL',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: MovieCanonicalEditField.coverImage,
          section: LibraryEditFormSection.artwork,
          controller: fields.controller(MovieCanonicalEditField.coverImage),
          label: 'Cover Image URL',
        ),
        LibraryEditFormFieldSpec(
          id: MovieCanonicalEditField.synopsis,
          section: LibraryEditFormSection.description,
          controller: fields.controller(MovieCanonicalEditField.synopsis),
          label: 'Synopsis',
          maxLines: 8,
        ),
      ],
      sectionTitles: const {
        LibraryEditFormSection.details: 'Details',
        LibraryEditFormSection.artwork: 'Cover Image',
        LibraryEditFormSection.description: 'Synopsis',
      },
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = selection;
    final meta = result.kindItem.kindCapability.mapTransport(
        (transport) => MovieCatalogMetadata.fromJson(transport.kindData));
    final parsedGenres = movieEdit.genresEditController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final updatedMeta = meta.copyWith(
      runtimeMinutes: int.tryParse(movieEdit.runtimeController.text),
      genres: parsedGenres.isNotEmpty ? parsedGenres : meta.genres,
      cast: movieEdit.castCredits
          .map((credit) => MoviePersonCredit(
                name: credit.nameController.text.trim(),
                role: emptyToNull(credit.roleController.text.trim()),
              ))
          .where((credit) => credit.name.isNotEmpty)
          .toList(),
      crew: movieEdit.crewCredits
          .map((credit) => MoviePersonCredit(
                name: credit.nameController.text.trim(),
                role: emptyToNull(credit.roleController.text.trim()),
              ))
          .where((credit) => credit.name.isNotEmpty)
          .toList(),
      ageRating: emptyToNull(movieEdit.ageRatingController.text),
      audienceRating: emptyToNull(movieEdit.audienceRatingController.text),
      editionTitle: emptyToNull(movieEdit.editionTitleController.text),
      variant: emptyToNull(movieEdit.variantController.text),
      barcode: emptyToNull(movieEdit.barcodeController.text),
      physicalFormat: movieEdit.physicalFormatId,
      physicalFormatLabel:
          emptyToNull(movieEdit.physicalFormatLabelController.text),
      publisher: emptyToNull(movieEdit.publisherController.text),
      country: emptyToNull(movieEdit.countryController.text) ?? meta.country,
      language: emptyToNull(movieEdit.languageController.text) ?? meta.language,
      releaseDate: parseDate(movieEdit.releaseDateController.text),
      links: movieEdit.buildUpdatedTrailerUrls(meta.links),
      screenRatio: emptyToNull(screenRatioController.text),
      audioTracks: emptyToNull(audioTracksController.text),
      subtitles: emptyToNull(subtitlesController.text),
      layers: emptyToNull(layersController.text),
      color: emptyToNull(colorController.text),
      nrDiscs: int.tryParse(nrDiscsController.text),
    );
    result = result.copyWith(
      kindItem: result.kindItem.kindCapability.mapTransport(
        (transport) => CatalogSearchCandidate.fromItem(
          transport.withKindData(updatedMeta),
        ),
      ),
    );
    return result;
  }

  @override
  TextEditingController get releaseDateController =>
      movieEdit.releaseDateController;

  @override
  TextEditingController get releaseYearController =>
      movieEdit.releaseYearController;

  void dispose() {
    movieEdit.dispose();
  }
}

LibraryEditSessionBundle createMovieEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry = MovieLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final video = entry?.personal.details;
  final metadata = item.kindCapability.mapTransport(
      (transport) => MovieCatalogMetadata.fromJson(transport.kindData));
  final movie = metadata;
  final movieEdit = MovieEditController(
    itemId: item.reference.id,
    catalogRef: item.reference,
    initialRuntime: movie.runtimeMinutes?.toString() ?? '',
    initialAgeRating: movie.ageRating ?? '',
    initialAudienceRating: movie.audienceRating ?? '',
    initialGenres: movie.genres.join(', '),
    initialEditionTitle: movie.editionTitle ??
        (item.movieCatalogFields.titleExtension ??
                item.kindCapability
                    .mapTransport((transport) => transport)
                    .editionTitle)
            ?.trim() ??
        '',
    initialVariant: movie.variant ?? '',
    initialBarcode: movie.barcode ?? '',
    initialPhysicalFormatLabel:
        movie.physicalFormatLabel ?? movie.variant ?? '',
    initialPhysicalFormatId: movie.physicalFormat,
    initialPublisher: movie.publisher ?? movie.studio ?? '',
    initialCountry: movie.country ?? '',
    initialLanguage: movie.language ?? movie.originalLanguage ?? '',
    initialReleaseDate:
        movie.releaseDate == null ? '' : formatDate(movie.releaseDate!),
    initialReleaseYear: movie.releaseDate?.year.toString() ?? '',
    initialCreators: [
      for (final creator in movie.creators)
        MovieCreditInput(
          name: creator['name']?.toString() ?? '',
          role: creator['role']?.toString() ?? creator['job']?.toString(),
          sourceType: creator['source_type']?.toString() ?? 'provider',
        ),
    ],
    initialTrailerLinks: movie.links,
  );
  movieEdit.initializeMovieEditors();

  final draft = MovieEditDraft(
    libraryEntry: entry,
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
    screenRatioController:
        textControllers.create(text: movie.screenRatio ?? ''),
    audioTracksController:
        textControllers.create(text: movie.audioTracks ?? ''),
    subtitlesController: textControllers.create(text: movie.subtitles ?? ''),
    layersController: textControllers.create(text: movie.layers ?? ''),
    colorController: textControllers.create(text: movie.color ?? ''),
    nrDiscsController:
        textControllers.create(text: movie.nrDiscs?.toString() ?? ''),
    hdrFormats: List<String>.from(video?.hdrFormats ?? const <String>[]),
    movieEdit: movieEdit,
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}
