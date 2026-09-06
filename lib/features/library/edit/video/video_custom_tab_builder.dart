import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/video/video_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/edit/video/video_edit_controller.dart';
import 'package:collectarr_app/features/library/edit/video/tabs/video_cast_tab.dart';
import 'package:collectarr_app/features/library/edit/video/tabs/video_crew_tab.dart';
import 'package:collectarr_app/features/library/edit/video/tabs/video_discs_tab.dart';
import 'package:collectarr_app/features/library/edit/video/tabs/video_edition_tab.dart';
import 'package:collectarr_app/features/library/edit/video/tabs/video_links_tab.dart';
import 'package:collectarr_app/features/library/edit/video/tabs/video_media_tab.dart';
import 'package:collectarr_app/features/library/edit/video/tabs/video_specs_tab.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

Widget? buildVideoCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditDraft draft,
  required Color accent,
  required LibraryEditScope scope,
  required CatalogItem item,
  required VoidCallback markDirty,
}) {
  final videoEdit = (draft.kindDetails is VideoEditDraftContract)
      ? (draft.kindDetails as VideoEditDraftContract).videoEdit
      : VideoEditController(itemId: item.id);

  return switch (tabId) {
    'edition' => VideoEditEditionTab(
        draft: draft,
        accent: accent,
        physicalFormats: const [],
      ),
    'specs' => VideoEditSpecsTab(
        draft: draft,
        videoEdit: videoEdit,
        accent: accent,
        audioTrackOptions: const [],
        subtitleOptions: const [],
        layersOptions: const [],
        colorOptions: const [],
      ),
    'cast' => VideoEditCastTab(
        accent: accent,
        videoEdit: videoEdit,
      ),
    'crew' => VideoEditCrewTab(
        accent: accent,
        videoEdit: videoEdit,
      ),
    'discs' => VideoEditDiscsTab(
        item: item,
        accent: accent,
      ),
    'links' => VideoEditLinksTab(
        item: item,
        accent: accent,
        videoEdit: videoEdit,
      ),
    'media' => VideoEditMediaTab(
        draft: draft,
        videoEdit: videoEdit,
        accent: accent,
        countryOptions: const [],
        languageOptions: const [],
        ageRatingOptions: const [],
        audienceRatingOptions: const [],
        genreOptions: const [],
      ),
    _ => null,
  };
}
