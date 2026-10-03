import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_media_custom_tab_builder.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_episode_media_map_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_episodes_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_catalog_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:flutter/material.dart';

Widget? buildTvCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final tvDraft = draft.session.catalogItemSession;
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
  final mediaEdit = tvDraft.mediaEdit;
  return switch (tabId) {
    'episodes' || 'tv_episodes' => TvEpisodesTab(
        type: draft.type,
        item: item.kindCapability.mapTransport((transport) => transport),
        accent: accent,
        mediaEdit: mediaEdit,
      ),
    'catalog_media' => TvCatalogMediaTab(
        accent: accent,
        mediaEdit: mediaEdit,
      ),
    'episode_media_map' => TvEpisodeMediaMapTab(
        type: draft.type,
        item: item.kindCapability.mapTransport((transport) => transport),
        accent: accent,
        mediaEdit: mediaEdit,
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
