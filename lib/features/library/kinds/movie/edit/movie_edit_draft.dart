import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

class MovieEditDraft extends KindEditDraft {
  MovieEditDraft({
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
  OwnedDetailsDraft toDetailsDraft() => MovieOwnedDetailsDraft(
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

KindEditDraft createMovieEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final movie = ownedItem?.movieDetails;
  return MovieEditDraft(
    featuresController: textControllers.create(text: movie?.features ?? ''),
    boxSetNameController: textControllers.create(text: movie?.boxSetName ?? ''),
    regionController: textControllers.create(text: movie?.region ?? ''),
    packagingController: textControllers.create(text: movie?.packaging ?? ''),
    distributorController:
        textControllers.create(text: movie?.distributor ?? ''),
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
    hdrFormats: List<String>.from(movie?.hdrFormats ?? const <String>[]),
  );
}
