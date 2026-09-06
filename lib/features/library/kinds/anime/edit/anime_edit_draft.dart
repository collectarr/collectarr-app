import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/video/video_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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
  OwnedDetailsDraft toDetailsDraft() => AnimeOwnedDetailsDraft(
        features: emptyToNull(featuresController.text),
        hdrFormats: hdrFormats,
        boxSetName: emptyToNull(boxSetNameController.text),
        region: emptyToNull(regionController.text),
        packaging: emptyToNull(packagingController.text),
        distributor: emptyToNull(distributorController.text),
      );

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = videoEdit.applyVideoSelectionEdits(selection);
    if (result.tracking != null) {
      final seasonNumber = int.tryParse(seasonNumberController.text);
      final episodeNumber = int.tryParse(episodeNumberController.text);
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

LibraryEditKindDraft createAnimeEditDraft({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final video = ownedItem?.details as AnimeOwnedDetails?;
  final metadata = item.kindMetadata;
  final anime = metadata is AnimeMetadata ? metadata : null;
  final videoEdit = VideoEditController(
    item: item,
    initialCreators: anime?.creators ?? const <Map<String, dynamic>>[],
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
