import 'package:flutter/material.dart';

/// Sealed domain hierarchy for kind-specific edit drafts.
abstract class KindEditDraft {
  const KindEditDraft();
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
}

/// Kind-specific edit state for Music items.
class MusicEditDraft extends KindEditDraft {
  MusicEditDraft({
    required this.storageDeviceController,
    required this.storageSlotController,
  });

  final TextEditingController storageDeviceController;
  final TextEditingController storageSlotController;
}

/// Fallback kind edit state for generic catalog items.
class GenericEditDraft extends KindEditDraft {
  const GenericEditDraft();
}
