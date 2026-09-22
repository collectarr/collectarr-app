import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft_contract.dart';

class MovieEditDraft
    with LibraryWorkEditSessionDefaults, LibraryCopyEditSessionDefaults
    implements MovieEditDraftContract {
  MovieEditDraft({
    this.ownedItem,
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

  final MovieOwnedItem? ownedItem;

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
  JsonEncodable toDetailsDraft() => MovieOwnedDetailsDraft(
        features: emptyToNull(featuresController.text),
        hdrFormats: hdrFormats,
        boxSetName: emptyToNull(boxSetNameController.text),
        region: emptyToNull(regionController.text),
        packaging: emptyToNull(packagingController.text),
        distributor: emptyToNull(distributorController.text),
      );

  @override
  void initializePersonalState(PersonalStateDraft personal) {
    final item = ownedItem;
    if (item == null) return;
    personal.ownerLabelController.text = item.ownerLabel ?? '';
    personal.conditionController.text = item.condition ?? '';
    personal.gradeController.text = item.grade ?? '';
    personal.purchaseDateController.text =
        item.purchaseDate == null ? '' : formatDate(item.purchaseDate!);
    personal.priceController.text = item.pricePaidCents == null
        ? ''
        : (item.pricePaidCents! / 100).toStringAsFixed(2);
    personal.currencyController.text = item.currency ?? '';
    personal.quantityController.text = item.quantity.toString();
    personal.indexNumberController.text = item.indexNumber?.toString() ?? '';
    personal.notesController.text = item.personalNotes ?? '';
    personal.tagsController.text = item.tags ?? '';
    personal.sellPriceController.text = item.sellPriceCents == null
        ? ''
        : (item.sellPriceCents! / 100).toStringAsFixed(2);
    personal.soldToController.text = item.soldTo ?? '';
    personal.purchaseStoreController.text = item.purchaseStore ?? '';
    personal.marketValueController.text = item.marketValueCents == null
        ? ''
        : (item.marketValueCents! / 100).toStringAsFixed(2);
    personal.selectedLocationId = item.locationId;
    personal.soldAt = item.soldAt;
    personal.collectionStatus = item.collectionStatus;
  }

  @override
  MovieOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedItemRef ownedRef,
    required PersonalStateDraft personal,
  }) {
    final targetRef = personal.selectedOwnedTargetRef;
    return MovieOwnedItemUpdatePayload(
      targetRef: targetRef == null ? const Patch.clear() : Patch.set(targetRef),
      quantity: Patch.set(parseInt(personal.quantityController.text) ?? 1),
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
      details: Patch.set(toDetailsDraft() as MovieOwnedDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = selection;
    final meta =
        result.kindItem.mapTransport((transport) => transport).kindMetadata;
    if (meta is MovieCatalogMetadata) {
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
        language:
            emptyToNull(movieEdit.languageController.text) ?? meta.language,
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
        kindItem: result.kindItem.mapTransport(
          (transport) => CatalogSearchCandidate.fromItem(
            transport.withKindMetadata(updatedMeta),
          ),
        ),
      );
    }
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
  LibraryOwnedItemDispatch? ownedItemDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final owned = MovieOwnedItemProjection.fromDispatch(ownedItemDispatch);
  final video = owned?.details;
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  final movie = metadata is MovieCatalogMetadata ? metadata : null;
  final movieEdit = MovieEditController(
    itemId: item.id,
    catalogRef: item.catalogRef,
    initialRuntime: movie?.runtimeMinutes?.toString() ?? '',
    initialAgeRating: movie?.ageRating ?? '',
    initialAudienceRating: movie?.audienceRating ?? '',
    initialGenres: movie?.genres.join(', ') ?? '',
    initialEditionTitle: movie?.editionTitle ??
        (item.editMetadata.titleExtension ??
                item.mapTransport((transport) => transport).editionTitle)
            ?.trim() ??
        '',
    initialVariant: movie?.variant ?? '',
    initialBarcode: movie?.barcode ?? '',
    initialPhysicalFormatLabel:
        movie?.physicalFormatLabel ?? movie?.variant ?? '',
    initialPhysicalFormatId: movie?.physicalFormat,
    initialPublisher: movie?.publisher ?? movie?.studio ?? '',
    initialCountry: movie?.country ?? '',
    initialLanguage: movie?.language ?? movie?.originalLanguage ?? '',
    initialReleaseDate:
        movie?.releaseDate == null ? '' : formatDate(movie!.releaseDate!),
    initialReleaseYear: movie?.releaseDate?.year.toString() ?? '',
    initialCreators: [
      for (final creator in movie?.creators ?? const <Map<String, dynamic>>[])
        MovieCreditInput(
          name: creator['name']?.toString() ?? '',
          role: creator['role']?.toString() ?? creator['job']?.toString(),
          sourceType: creator['source_type']?.toString() ?? 'provider',
        ),
    ],
    initialTrailerLinks: movie?.links ?? const <TrailerLinkDto>[],
  );
  movieEdit.initializeMovieEditors();

  final draft = MovieEditDraft(
    ownedItem: owned,
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
    screenRatioController:
        textControllers.create(text: movie?.screenRatio ?? ''),
    audioTracksController:
        textControllers.create(text: movie?.audioTracks ?? ''),
    subtitlesController: textControllers.create(text: movie?.subtitles ?? ''),
    layersController: textControllers.create(text: movie?.layers ?? ''),
    colorController: textControllers.create(text: movie?.color ?? ''),
    nrDiscsController:
        textControllers.create(text: movie?.nrDiscs?.toString() ?? ''),
    hdrFormats: List<String>.from(video?.hdrFormats ?? const <String>[]),
    movieEdit: movieEdit,
  );
  return LibraryEditSessionBundle(
    workSession: draft,
    releaseSession: draft,
    copySession: draft,
    disposeSession: draft.dispose,
  );
}
