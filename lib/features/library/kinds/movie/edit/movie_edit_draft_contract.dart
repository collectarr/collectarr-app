import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:flutter/material.dart';

abstract class MovieEditDraftContract implements LibraryEditKindDraft {
  TextEditingController get audioTracksController;
  TextEditingController get subtitlesController;
  TextEditingController get layersController;
  TextEditingController get colorController;
  TextEditingController get nrDiscsController;
  TextEditingController get screenRatioController;
  TextEditingController get regionController;
  TextEditingController get packagingController;
  TextEditingController get distributorController;
  TextEditingController get featuresController;
  TextEditingController get boxSetNameController;
  TextEditingController get releaseDateController;
  TextEditingController get releaseYearController;
  List<String> get hdrFormats;
  MovieEditController get movieEdit;
}
