import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/edit/video_edit_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/_shared/video/edit/video_kind_edit_draft.dart';

class AnimeEditDraft extends KindEditDraft implements VideoKindEditDraft {
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
    required this.videoEdit,
  });

  final TextEditingController featuresController;
  final TextEditingController boxSetNameController;
  final TextEditingController regionController;
  final TextEditingController packagingController;
  final TextEditingController distributorController;
  final TextEditingController screenRatioController;
  final TextEditingController audioTracksController;
  final TextEditingController subtitlesController;
  final TextEditingController layersController;
  final TextEditingController colorController;
  final TextEditingController nrDiscsController;

  List<String> hdrFormats;
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
  void dispose() {
    videoEdit.dispose();
  }
}

KindEditDraft createAnimeEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final video = ownedItem?.animeDetails;
  final videoEdit = VideoEditController(item: item);
  videoEdit.initializeVideoEditors();

  final payload = item.kindMetadata.toSyncPayload();
  return AnimeEditDraft(
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
    screenRatioController:
        textControllers.create(text: payload['screen_ratio']?.toString() ?? ''),
    audioTracksController:
        textControllers.create(text: payload['audio_tracks']?.toString() ?? ''),
    subtitlesController:
        textControllers.create(text: payload['subtitles']?.toString() ?? ''),
    layersController:
        textControllers.create(text: payload['layers']?.toString() ?? ''),
    colorController:
        textControllers.create(text: payload['color']?.toString() ?? ''),
    nrDiscsController:
        textControllers.create(text: payload['nr_discs']?.toString() ?? ''),
    hdrFormats: List<String>.from(video?.hdrFormats ?? const <String>[]),
    videoEdit: videoEdit,
  );
}
