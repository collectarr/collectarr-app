import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_draft.dart';
import 'package:flutter/material.dart';

abstract class AnimeEditDraftContract
    implements
        LibraryCatalogItemEditSession,
        LibraryEntryEditSession,
        AnimeCatalogFormDraft {
  TextEditingController get regionController;
  TextEditingController get packagingController;
  TextEditingController get distributorController;
  TextEditingController get featuresController;
  TextEditingController get boxSetNameController;
  String? get physicalFormatId;
  set physicalFormatId(String? value);
  List<String> get hdrFormats;
  AnimeEditController get animeEdit;
}
