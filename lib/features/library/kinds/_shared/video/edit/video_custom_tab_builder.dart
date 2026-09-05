import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/edit/video_kind_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/edit/tabs/tv_episodes_tab.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/edit/tabs/tv_release_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/edit/tabs/tv_episode_disc_map_tab.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/edit/video_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/edit/video_edit_tabs.dart';
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
  final videoEdit = (draft.kindDetails is VideoKindEditDraft)
      ? (draft.kindDetails as VideoKindEditDraft).videoEdit
      : VideoEditController(item: item);

  return switch (tabId) {
    'episodes' || 'tv_episodes' => TvEpisodesTab(
        type: draft.type,
        item: item,
        accent: accent,
        videoEdit: videoEdit,
      ),
    'release_media' => TvReleaseMediaTab(
        accent: accent,
        videoEdit: videoEdit,
      ),
    'episode_map' => TvEpisodeDiscMapTab(
        type: draft.type,
        item: item,
        accent: accent,
        videoEdit: videoEdit,
      ),
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
