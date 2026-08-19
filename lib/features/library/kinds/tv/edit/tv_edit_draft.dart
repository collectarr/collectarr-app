import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

class TvEditDraft extends KindEditDraft {
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
  final List<String> hdrFormats;

  @override
  OwnedDetailsDraft toDetailsDraft() => TvOwnedDetailsDraft(
        features: featuresController.text.trim().isEmpty
            ? null
            : featuresController.text.trim(),
        boxSetName: boxSetNameController.text.trim().isEmpty
            ? null
            : boxSetNameController.text.trim(),
        region: regionController.text.trim().isEmpty
            ? null
            : regionController.text.trim(),
        packaging: packagingController.text.trim().isEmpty
            ? null
            : packagingController.text.trim(),
        distributor: distributorController.text.trim().isEmpty
            ? null
            : distributorController.text.trim(),
        hdrFormats: List.unmodifiable(hdrFormats),
      );
}

KindEditDraft createTvEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final tv = ownedItem?.tvDetails;
  return TvEditDraft(
    featuresController: textControllers.create(text: tv?.features ?? ''),
    boxSetNameController: textControllers.create(text: tv?.boxSetName ?? ''),
    regionController: textControllers.create(text: tv?.region ?? ''),
    packagingController: textControllers.create(text: tv?.packaging ?? ''),
    distributorController: textControllers.create(text: tv?.distributor ?? ''),
    screenRatioController:
        textControllers.create(text: item.video?.screenRatio ?? ''),
    audioTracksController:
        textControllers.create(text: item.video?.audioTracks ?? ''),
    subtitlesController:
        textControllers.create(text: item.video?.subtitles ?? ''),
    layersController: textControllers.create(text: item.video?.layers ?? ''),
    colorController: textControllers.create(text: item.video?.color ?? ''),
    nrDiscsController:
        textControllers.create(text: item.video?.nrDiscs?.toString() ?? ''),
    hdrFormats: List<String>.from(tv?.hdrFormats ?? const <String>[]),
  );
}
