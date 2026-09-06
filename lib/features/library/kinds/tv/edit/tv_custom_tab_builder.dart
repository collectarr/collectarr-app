import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/video/video_custom_tab_builder.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_episode_disc_map_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_episodes_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_release_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:flutter/material.dart';

Widget? buildTvCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditDraft draft,
  required Color accent,
  required LibraryEditScope scope,
  required CatalogItem item,
  required VoidCallback markDirty,
}) {
  final tvDraft = draft.kindDetails;
  if (tvDraft is! TvEditDraft) {
    return buildVideoCustomTabView(
      tabId: tabId,
      context: context,
      draft: draft,
      accent: accent,
      scope: scope,
      item: item,
      markDirty: markDirty,
    );
  }
  final releaseMediaEdit = tvDraft.releaseMediaEdit;
  return switch (tabId) {
    'episodes' || 'tv_episodes' => TvEpisodesTab(
        type: draft.type,
        item: item,
        accent: accent,
        releaseMediaEdit: releaseMediaEdit,
      ),
    'release_media' => TvReleaseMediaTab(
        accent: accent,
        releaseMediaEdit: releaseMediaEdit,
      ),
    'episode_map' => TvEpisodeDiscMapTab(
        type: draft.type,
        item: item,
        accent: accent,
        releaseMediaEdit: releaseMediaEdit,
      ),
    _ => buildVideoCustomTabView(
        tabId: tabId,
        context: context,
        draft: draft,
        accent: accent,
        scope: scope,
        item: item,
        markDirty: markDirty,
      ),
  };
}
