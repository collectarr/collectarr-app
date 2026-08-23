import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

/// Sealed domain hierarchy for kind-specific edit drafts.
abstract class KindEditDraft {
  const KindEditDraft();

  OwnedDetailsDraft toDetailsDraft();
}

/// Kind-specific edit state for Comic/Manga items.
class ComicEditDraft extends KindEditDraft {
  ComicEditDraft({
    required this.rawOrSlabbedController,
    required this.gradingCompanyController,
    required this.graderNotesController,
    required this.signedByController,
    required this.labelTypeController,
    required this.pageQualityController,
    required this.certificationNumberController,
    required this.coverPriceController,
    required this.keyReasonController,
    required this.keyCategoryController,
    required this.keyComic,
    required this.lastBagBoardDate,
  });

  final TextEditingController rawOrSlabbedController;
  final TextEditingController gradingCompanyController;
  final TextEditingController graderNotesController;
  final TextEditingController signedByController;
  final TextEditingController labelTypeController;
  final TextEditingController pageQualityController;
  final TextEditingController certificationNumberController;
  final TextEditingController coverPriceController;
  final TextEditingController keyReasonController;
  final TextEditingController keyCategoryController;

  bool keyComic;
  DateTime? lastBagBoardDate;

  @override
  OwnedDetailsDraft toDetailsDraft() => ComicOwnedDetailsDraft(
        rawOrSlabbed: emptyToNull(rawOrSlabbedController.text),
        gradingCompany: emptyToNull(gradingCompanyController.text),
        graderNotes: emptyToNull(graderNotesController.text),
        signedBy: emptyToNull(signedByController.text),
        labelType: emptyToNull(labelTypeController.text),
        pageQuality: emptyToNull(pageQualityController.text),
        certificationNumber: emptyToNull(certificationNumberController.text),
        keyComic: keyComic,
        keyReason: emptyToNull(keyReasonController.text),
        keyCategory: emptyToNull(keyCategoryController.text),
        coverPriceCents: parseMoneyCents(coverPriceController.text),
        lastBagBoardDate: lastBagBoardDate,
      );
}

/// Kind-specific edit state for Movie/TV/Anime items.
class VideoEditDraft extends KindEditDraft {
  VideoEditDraft({
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

  List<String> hdrFormats;

  @override
  OwnedDetailsDraft toDetailsDraft() => MovieOwnedDetailsDraft(
        features: emptyToNull(featuresController.text),
        hdrFormats: hdrFormats,
        boxSetName: emptyToNull(boxSetNameController.text),
        region: emptyToNull(regionController.text),
        packaging: emptyToNull(packagingController.text),
        distributor: emptyToNull(distributorController.text),
      );
}

/// Kind-specific edit state for Video Game items.
class GameEditDraft extends KindEditDraft {
  GameEditDraft({
    required this.gameCompleteness,
    required this.gameHasBox,
    required this.gameHasManual,
    required this.gamePriceChartingId,
    required this.gameCoreRegion,
    required this.gameValueIsLocked,
  });

  String? gameCompleteness;
  bool? gameHasBox;
  bool? gameHasManual;
  String? gamePriceChartingId;
  String? gameCoreRegion;
  bool gameValueIsLocked;

  @override
  OwnedDetailsDraft toDetailsDraft() => GameOwnedDetailsDraft(
        completeness: gameCompleteness,
        hasBox: gameHasBox,
        hasManual: gameHasManual,
        priceChartingId: gamePriceChartingId,
        coreRegion: gameCoreRegion,
        valueIsLocked: gameValueIsLocked,
      );
}

/// Kind-specific edit state for Music items.
class MusicEditDraft extends KindEditDraft {
  MusicEditDraft({
    required this.storageDeviceController,
    required this.storageSlotController,
  });

  final TextEditingController storageDeviceController;
  final TextEditingController storageSlotController;

  @override
  OwnedDetailsDraft toDetailsDraft() => MusicOwnedDetailsDraft(
        storageDevice: emptyToNull(storageDeviceController.text),
        storageSlot: emptyToNull(storageSlotController.text),
      );
}

/// Kind-specific edit state for Book items.
class BookEditDraft extends KindEditDraft {
  BookEditDraft({
    required this.signedByController,
  });

  final TextEditingController signedByController;

  @override
  OwnedDetailsDraft toDetailsDraft() => BookOwnedDetailsDraft(
        signedBy: emptyToNull(signedByController.text),
      );
}

/// Fallback kind edit state for generic catalog items.
class GenericEditDraft extends KindEditDraft {
  const GenericEditDraft();

  @override
  OwnedDetailsDraft toDetailsDraft() => const GenericOwnedDetailsDraft();
}

// -----------------------------------------------------------------------------
// Kind-owned Edit Draft Factories
// -----------------------------------------------------------------------------

KindEditDraft createComicEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final comic = ownedItem?.comicDetails;
  return ComicEditDraft(
    rawOrSlabbedController:
        textControllers.create(text: comic?.rawOrSlabbed ?? ''),
    gradingCompanyController:
        textControllers.create(text: comic?.gradingCompany ?? ''),
    graderNotesController:
        textControllers.create(text: comic?.graderNotes ?? ''),
    signedByController: textControllers.create(text: comic?.signedBy ?? ''),
    labelTypeController: textControllers.create(text: comic?.labelType ?? ''),
    pageQualityController:
        textControllers.create(text: comic?.pageQuality ?? ''),
    certificationNumberController:
        textControllers.create(text: comic?.certificationNumber ?? ''),
    coverPriceController: textControllers.create(
      text: comic?.coverPriceCents == null
          ? ''
          : (comic!.coverPriceCents! / 100).toStringAsFixed(2),
    ),
    keyReasonController: textControllers.create(text: comic?.keyReason ?? ''),
    keyCategoryController:
        textControllers.create(text: comic?.keyCategory ?? ''),
    keyComic: comic?.keyComic ?? false,
    lastBagBoardDate: comic?.lastBagBoardDate,
  );
}

KindEditDraft createVideoEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final video = ownedItem?.videoLikeDetails;
  return VideoEditDraft(
    featuresController: textControllers.create(text: video?.features ?? ''),
    boxSetNameController: textControllers.create(text: video?.boxSetName ?? ''),
    regionController: textControllers.create(text: video?.region ?? ''),
    packagingController: textControllers.create(text: video?.packaging ?? ''),
    distributorController:
        textControllers.create(text: video?.distributor ?? ''),
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
    hdrFormats: List<String>.from(video?.hdrFormats ?? const <String>[]),
  );
}

KindEditDraft createGameEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final game = ownedItem?.gameDetails;
  return GameEditDraft(
    gameCompleteness: game?.completeness,
    gameHasBox: game?.hasBox,
    gameHasManual: game?.hasManual,
    gamePriceChartingId: game?.priceChartingId,
    gameCoreRegion: game?.coreRegion,
    gameValueIsLocked: game?.valueIsLocked ?? false,
  );
}

KindEditDraft createMusicEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final music = ownedItem?.musicDetails;
  return MusicEditDraft(
    storageDeviceController:
        textControllers.create(text: music?.storageDevice ?? ''),
    storageSlotController:
        textControllers.create(text: music?.storageSlot ?? ''),
  );
}

KindEditDraft createBookEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final book = ownedItem?.bookDetails;
  return BookEditDraft(
    signedByController: textControllers.create(text: book?.signedBy ?? ''),
  );
}

KindEditDraft createGenericEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  return const GenericEditDraft();
}
