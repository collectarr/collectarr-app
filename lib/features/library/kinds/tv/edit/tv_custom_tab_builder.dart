import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_custom_tab_builder.dart';
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
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final tvDraft = draft.kindDetails;
  if (tvDraft is! TvEditDraft) {
    return buildTvMediaCustomTabView(
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
        item: item.mapTransport((transport) => transport),
        accent: accent,
        releaseMediaEdit: releaseMediaEdit,
      ),
    'release_media' => TvReleaseMediaTab(
        accent: accent,
        releaseMediaEdit: releaseMediaEdit,
      ),
    'episode_map' => TvEpisodeDiscMapTab(
        type: draft.type,
        item: item.mapTransport((transport) => transport),
        accent: accent,
        releaseMediaEdit: releaseMediaEdit,
      ),
    _ => buildTvMediaCustomTabView(
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
