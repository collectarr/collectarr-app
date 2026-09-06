import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/video/video_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_release_media_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_draft.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_values.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/edit/video/video_edit_draft_contract.dart';

class TvEditDraft extends LibraryEditKindDraft
    implements VideoEditDraftContract {
  TvEditDraft({
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
    required this.releaseMediaEdit,
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
  final TvReleaseMediaEditController releaseMediaEdit;

  @override
  OwnedDetailsDraft toDetailsDraft() => TvOwnedDetailsDraft(
        features: emptyToNull(featuresController.text),
        hdrFormats: hdrFormats,
        boxSetName: emptyToNull(boxSetNameController.text),
        region: emptyToNull(regionController.text),
        packaging: emptyToNull(packagingController.text),
        distributor: emptyToNull(distributorController.text),
      );

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = selection;
    final seasonNumber = int.tryParse(seasonNumberController.text);
    final episodeNumber = int.tryParse(episodeNumberController.text);
    final metadata = result.item.kindMetadata;
    if (metadata is TvSeriesMetadata) {
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
            cast: videoEdit.castCredits
                .map((credit) => TvPersonCredit(
                      name: credit.nameController.text.trim(),
                      role: emptyToNull(credit.roleController.text.trim()),
                    ))
                .where((credit) => credit.name.isNotEmpty)
                .toList(),
            crew: videoEdit.crewCredits
                .map((credit) => TvPersonCredit(
                      name: credit.nameController.text.trim(),
                      role: emptyToNull(credit.roleController.text.trim()),
                    ))
                .where((credit) => credit.name.isNotEmpty)
                .toList(),
            contentRating: emptyToNull(videoEdit.ageRatingController.text),
            variant: emptyToNull(videoEdit.variantController.text),
            barcode: emptyToNull(videoEdit.barcodeController.text),
            physicalFormat: videoEdit.physicalFormatId,
            physicalFormatLabel:
                emptyToNull(videoEdit.physicalFormatLabelController.text),
            publisher: emptyToNull(videoEdit.publisherController.text),
            country: emptyToNull(videoEdit.countryController.text) ??
                metadata.country,
            originalLanguage: emptyToNull(videoEdit.languageController.text) ??
                metadata.originalLanguage,
            firstAirDate: parseDate(videoEdit.releaseDateController.text),
            links: videoEdit.buildUpdatedTrailerUrls(metadata.links),
            seasonNumber: seasonNumber ?? metadata.seasonNumber,
            episodeNumber: episodeNumber ?? metadata.episodeNumber,
          ),
        ),
      );
    }
    if (result.tracking != null) {
      final episodeRatings = this.episodeRatings.isEmpty
          ? null
          : Map<String, int>.unmodifiable(this.episodeRatings);
      result = result.copyWith(
        trackingEntryMutation: (entry) => entry.copyWith(
          seasonNumber: seasonNumber ?? entry.seasonNumber,
          episodeNumber: episodeNumber ?? entry.episodeNumber,
          episodeRatings: episodeRatings,
        ),
      );
    }
    if (result.personal != null) {
      result = result.copyWith(
        personal: result.personal!.copyWith(
          features: emptyToNull(featuresController.text),
          hdrFormats: hdrFormats.isEmpty ? null : hdrFormats,
          boxSetName: emptyToNull(boxSetNameController.text),
          region: emptyToNull(regionController.text),
          packaging: emptyToNull(packagingController.text),
          distributor: emptyToNull(distributorController.text),
          screenRatio: emptyToNull(screenRatioController.text),
          audioTracks: emptyToNull(audioTracksController.text),
          subtitles: emptyToNull(subtitlesController.text),
          layers: emptyToNull(layersController.text),
          color: emptyToNull(colorController.text),
          nrDiscs: int.tryParse(nrDiscsController.text),
        ),
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

LibraryEditKindDraft createTvEditDraft({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final video = ownedItem?.details as TvOwnedDetails?;
  final metadata = item.kindMetadata;
  final tv = metadata is TvSeriesMetadata ? metadata : null;
  final videoEdit = VideoEditController(
    itemId: item.id,
    catalogRef: item.catalogRef,
    initialRuntime: tv?.episodeRuntimeMinutes?.toString() ?? '',
    initialAgeRating: tv?.contentRating ?? '',
    initialGenres: tv?.genres.join(', ') ?? '',
    initialEditionTitle: libraryKindTitleExtension(item) ?? '',
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
    initialCreators: tv?.creators ?? const <Map<String, dynamic>>[],
    initialTrailerLinks: tv?.links ?? const <TrailerLink>[],
  );
  final releaseMediaEdit = TvReleaseMediaEditController(
    item: item,
    initialDiscCount: tv?.releases
        .map((release) => release.discCount ?? 0)
        .fold<int>(0, (max, count) => count > max ? count : max),
  );
  videoEdit.initializeVideoEditors();

  return TvEditDraft(
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
    videoEdit: videoEdit,
    releaseMediaEdit: releaseMediaEdit,
  );
}
