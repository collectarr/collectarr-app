import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/video/video_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/edit/draft/video_kind_edit_draft.dart';

class MovieEditDraft extends KindEditDraft implements VideoKindEditDraft {
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
  @override
  final VideoEditController videoEdit;

  @override
  OwnedDetailsDraft toDetailsDraft() => MovieOwnedDetailsDraft(
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
    final meta = result.item.kindMetadata is MovieCatalogMetadata
        ? result.item.kindMetadata as MovieCatalogMetadata
        : null;
    if (meta != null) {
      final updatedMeta = meta.copyWith(
        screenRatio: emptyToNull(screenRatioController.text),
        audioTracks: emptyToNull(audioTracksController.text),
        subtitles: emptyToNull(subtitlesController.text),
        layers: emptyToNull(layersController.text),
        color: emptyToNull(colorController.text),
        nrDiscs: int.tryParse(nrDiscsController.text),
      );
      result = result.copyWith(
        item: result.item.copyWith(kindMetadata: updatedMeta),
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
    videoEdit.dispose();
  }
}

KindEditDraft createMovieEditDraft({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final video = ownedItem?.details as MovieOwnedDetails?;
  final metadata = item.kindMetadata;
  final movie = metadata is MovieCatalogMetadata ? metadata : null;
  final videoEdit = VideoEditController(
    item: item,
    initialCreators: movie?.creators ?? const <Map<String, dynamic>>[],
    initialDiscCount: movie?.nrDiscs,
  );
  videoEdit.initializeVideoEditors();

  return MovieEditDraft(
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
    videoEdit: videoEdit,
  );
}
