import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_media_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft_contract.dart';

class TvEditDraft
    with LibraryWorkEditSessionDefaults, LibraryCopyEditSessionDefaults
    implements TvEditDraftContract {
  TvEditDraft({
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
    required this.seasonNumberController,
    required this.episodeNumberController,
    required this.episodeRatings,
    required this.tvEdit,
    required this.releaseMediaEdit,
  });

  final TvOwnedItem? ownedItem;

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
  final TextEditingController seasonNumberController;
  final TextEditingController episodeNumberController;
  final Map<String, int> episodeRatings;
  @override
  final TvEditController tvEdit;
  final TvReleaseMediaEditController releaseMediaEdit;

  @override
  JsonEncodable toDetailsDraft() => TvOwnedDetailsDraft(
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
  TvOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedItemRef ownedRef,
    required PersonalStateDraft personal,
  }) {
    final targetRef = personal.selectedOwnedTargetRef;
    return TvOwnedItemUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as TvOwnedDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = selection;
    final seasonNumber = int.tryParse(seasonNumberController.text);
    final episodeNumber = int.tryParse(episodeNumberController.text);
    final metadata =
        result.kindItem.mapTransport((transport) => transport).kindMetadata;
    if (metadata is TvSeriesMetadata) {
      final parsedGenres = tvEdit.genresEditController.text
          .split(RegExp(r'[,\r\n]+'))
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      result = result.copyWith(
        kindItem: result.kindItem.mapTransport(
          (transport) => CatalogSearchCandidate.fromItem(
            transport.withKindMetadata(
              metadata.copyWith(
                episodeRuntimeMinutes:
                    int.tryParse(tvEdit.runtimeController.text),
                genres:
                    parsedGenres.isNotEmpty ? parsedGenres : metadata.genres,
                cast: tvEdit.castCredits
                    .map((credit) => TvPersonCredit(
                          name: credit.nameController.text.trim(),
                          role: emptyToNull(credit.roleController.text.trim()),
                        ))
                    .where((credit) => credit.name.isNotEmpty)
                    .toList(),
                crew: tvEdit.crewCredits
                    .map((credit) => TvPersonCredit(
                          name: credit.nameController.text.trim(),
                          role: emptyToNull(credit.roleController.text.trim()),
                        ))
                    .where((credit) => credit.name.isNotEmpty)
                    .toList(),
                contentRating: emptyToNull(tvEdit.ageRatingController.text),
                variant: emptyToNull(tvEdit.variantController.text),
                barcode: emptyToNull(tvEdit.barcodeController.text),
                physicalFormat: tvEdit.physicalFormatId,
                physicalFormatLabel:
                    emptyToNull(tvEdit.physicalFormatLabelController.text),
                publisher: emptyToNull(tvEdit.publisherController.text),
                country: emptyToNull(tvEdit.countryController.text) ??
                    metadata.country,
                originalLanguage: emptyToNull(tvEdit.languageController.text) ??
                    metadata.originalLanguage,
                firstAirDate: parseDate(tvEdit.releaseDateController.text),
                links: tvEdit.buildUpdatedTrailerUrls(metadata.links),
                seasonNumber: seasonNumber ?? metadata.seasonNumber,
                episodeNumber: episodeNumber ?? metadata.episodeNumber,
              ),
            ),
          ),
        ),
      );
    }
    if (result.tracking != null) {
      final episodeRatings = this.episodeRatings.isEmpty
          ? null
          : Map<String, int>.unmodifiable(this.episodeRatings);
      result = result.copyWith(
        trackingKindPatch: TvTrackingCoordinatesPatch(
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
          episodeRatings: episodeRatings,
          setSeasonNumber: seasonNumber != null,
          setEpisodeNumber: episodeNumber != null,
          setEpisodeRatings: episodeRatings != null,
        ),
      );
    }
    return result;
  }

  @override
  TextEditingController get releaseDateController =>
      tvEdit.releaseDateController;

  @override
  TextEditingController get releaseYearController =>
      tvEdit.releaseYearController;

  void dispose() {
    seasonNumberController.dispose();
    episodeNumberController.dispose();
    tvEdit.dispose();
  }
}

LibraryEditSessionBundle createTvEditDraft({
  required CatalogSearchCandidate item,
  LibraryOwnedItemDispatch? ownedItemDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final owned = TvOwnedItemProjection.fromDispatch(ownedItemDispatch);
  final video = owned?.details;
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  final tv = metadata is TvSeriesMetadata ? metadata : null;
  final tvEdit = TvEditController(
    itemId: item.id,
    catalogRef: item.catalogRef,
    initialRuntime: tv?.episodeRuntimeMinutes?.toString() ?? '',
    initialAgeRating: tv?.contentRating ?? '',
    initialGenres: tv?.genres.join(', ') ?? '',
    initialEditionTitle: (item.editMetadata.titleExtension ??
                item.mapTransport((transport) => transport).editionTitle)
            ?.trim() ??
        '',
    initialVariant: tv?.variant ?? '',
    initialBarcode: tv?.barcode ?? '',
    initialPhysicalFormatLabel: tv?.physicalFormatLabel ?? tv?.variant ?? '',
    initialPhysicalFormatId: tv?.physicalFormat,
    initialPublisher: tv?.publisher ?? tv?.network ?? '',
    initialCountry: tv?.country ?? '',
    initialLanguage: tv?.originalLanguage ?? '',
    initialReleaseDate:
        tv?.firstAirDate == null ? '' : formatDate(tv!.firstAirDate!),
    initialReleaseYear: tv?.firstAirDate?.year.toString() ?? '',
    initialCreators: [
      for (final creator in tv?.creators ?? const <Map<String, dynamic>>[])
        TvCreditInput(
          name: creator['name']?.toString() ?? '',
          role: creator['role']?.toString() ?? creator['job']?.toString(),
          sourceType: creator['source_type']?.toString() ?? 'provider',
        ),
    ],
    initialTrailerLinks: tv?.links ?? const <TrailerLinkDto>[],
  );
  final releaseMediaEdit = TvReleaseMediaEditController(
    item: item.mapTransport((transport) => transport),
    initialDiscCount: tv?.releases
        .map((release) => release.discCount ?? 0)
        .fold<int>(0, (max, count) => count > max ? count : max),
  );
  tvEdit.initializeTvEditors();

  final draft = TvEditDraft(
    ownedItem: owned,
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
    screenRatioController: textControllers.create(text: ''),
    audioTracksController: textControllers.create(text: ''),
    subtitlesController: textControllers.create(text: ''),
    layersController: textControllers.create(text: ''),
    colorController: textControllers.create(text: ''),
    nrDiscsController: textControllers.create(text: ''),
    hdrFormats: List<String>.from(video?.hdrFormats ?? const <String>[]),
    seasonNumberController: TextEditingController(
      text: tv?.seasonNumber?.toString() ?? '',
    ),
    episodeNumberController: TextEditingController(
      text: tv?.episodeNumber?.toString() ?? '',
    ),
    episodeRatings: const <String, int>{},
    tvEdit: tvEdit,
    releaseMediaEdit: releaseMediaEdit,
  );
  return LibraryEditSessionBundle(
    workSession: draft,
    releaseSession: draft,
    copySession: draft,
    disposeSession: draft.dispose,
  );
}
