import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/video/video_edit_controller.dart';
import 'package:collectarr_app/features/library/edit/video/video_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_entry.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_item.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/edit/video/video_edit_draft_contract.dart';

class AnimeEditDraft extends LibraryEditKindDraft
    implements VideoEditDraftContract {
  AnimeEditDraft({
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
    required this.videoEdit,
  });

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
  final VideoEditController videoEdit;

  @override
  JsonEncodable toDetailsDraft() => AnimeOwnedDetailsDraft(
        features: emptyToNull(featuresController.text),
        hdrFormats: hdrFormats,
        boxSetName: emptyToNull(boxSetNameController.text),
        region: emptyToNull(regionController.text),
        packaging: emptyToNull(packagingController.text),
        distributor: emptyToNull(distributorController.text),
      );

  @override
  AnimeOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required String ownedItemId,
    required PersonalStateDraft personal,
  }) {
    final targetRef = catalogRefForOwnedSelection(
      CatalogMediaKind.anime,
      anchorType: personal.selectedOwnedAnchorType,
      editionId: personal.selectedEditionId,
      variantId: personal.selectedVariantId,
      bundleReleaseId: personal.selectedBundleReleaseId,
    );
    return AnimeOwnedItemUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as AnimeOwnedDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = selection;
    final metadata = result.item.kindMetadata;
    if (metadata is AnimeMetadata) {
      final parsedGenres = videoEdit.genresEditController.text
          .split(RegExp(r'[,\r\n]+'))
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      result = result.copyWith(
        item: result.item.copyWith(
          kindMetadata: metadata.copyWith(
            episodeRuntimeMinutes:
                int.tryParse(videoEdit.runtimeController.text),
            genres: parsedGenres.isNotEmpty ? parsedGenres : metadata.genres,
            editionTitle: emptyToNull(videoEdit.editionTitleController.text),
            variant: emptyToNull(videoEdit.variantController.text),
            barcode: emptyToNull(videoEdit.barcodeController.text),
            physicalFormat: videoEdit.physicalFormatId,
            physicalFormatLabel:
                emptyToNull(videoEdit.physicalFormatLabelController.text),
            publisher: emptyToNull(videoEdit.publisherController.text),
            country: emptyToNull(videoEdit.countryController.text) ??
                metadata.country,
            language: emptyToNull(videoEdit.languageController.text) ??
                metadata.language,
            startDate: parseDate(videoEdit.releaseDateController.text),
            links: videoEdit.buildUpdatedTrailerUrls(metadata.links),
          ),
        ),
      );
    }
    if (result.tracking != null) {
      final seasonNumber = int.tryParse(seasonNumberController.text);
      final episodeNumber = int.tryParse(episodeNumberController.text);
      final episodeRatings = this.episodeRatings.isEmpty
          ? null
          : Map<String, int>.unmodifiable(this.episodeRatings);
      result = result.copyWith(
        trackingEntryMutation: (entry) {
          final coordinates = animeTrackingCoordinatesFor(entry);
          return animeTrackingEntryFor(entry).copyWithCoordinates(
            seasonNumber: seasonNumber ?? coordinates.seasonNumber,
            episodeNumber: episodeNumber ?? coordinates.episodeNumber,
            episodeRatings: episodeRatings ?? coordinates.episodeRatings,
          );
        },
      );
    }
    return result;
  }

  @override
  TextEditingController get releaseDateController =>
      videoEdit.releaseDateController;

  @override
  TextEditingController get releaseYearController =>
      videoEdit.releaseYearController;

  @override
  void dispose() {
    seasonNumberController.dispose();
    episodeNumberController.dispose();
    videoEdit.dispose();
  }
}

LibraryEditKindDraft createAnimeEditDraft({
  required LibraryAddCatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final video = AnimeOwnedItemProjection.tryFromOwnedItem(ownedItem)?.details;
  final metadata = item.kindMetadata;
  final anime = metadata is AnimeMetadata ? metadata : null;
  final videoEdit = VideoEditController(
    itemId: item.id,
    catalogRef: item.catalogRef,
    initialRuntime: anime?.episodeRuntimeMinutes?.toString() ?? '',
    initialGenres: anime?.genres.join(', ') ?? '',
    initialEditionTitle: anime?.editionTitle ??
        (item.titleExtension ?? item.editionTitle)?.trim() ??
        '',
    initialVariant: anime?.variant ?? '',
    initialBarcode: anime?.barcode ?? '',
    initialPhysicalFormatLabel:
        anime?.physicalFormatLabel ?? anime?.variant ?? '',
    initialPhysicalFormatId: anime?.physicalFormat,
    initialPublisher: anime?.publisher ?? '',
    initialCountry: anime?.country ?? '',
    initialLanguage: anime?.language ?? '',
    initialReleaseDate:
        anime?.startDate == null ? '' : formatDate(anime!.startDate!),
    initialReleaseYear: anime?.seasonYear?.toString() ??
        anime?.startDate?.year.toString() ??
        '',
    initialCreators: [
      for (final creator in anime?.creators ?? const <Map<String, dynamic>>[])
        VideoCreditInput(
          name: creator['name']?.toString() ?? '',
          role: creator['role']?.toString() ?? creator['job']?.toString(),
          sourceType: creator['source_type']?.toString() ?? 'provider',
        ),
    ],
    initialTrailerLinks: anime?.links ?? const <TrailerLinkDto>[],
  );
  videoEdit.initializeVideoEditors();

  return AnimeEditDraft(
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
    seasonNumberController: TextEditingController(),
    episodeNumberController: TextEditingController(
      text: anime?.episodeCount?.toString() ?? '',
    ),
    episodeRatings: const <String, int>{},
    videoEdit: videoEdit,
  );
}
