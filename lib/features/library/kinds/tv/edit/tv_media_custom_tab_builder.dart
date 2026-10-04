import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_episodes_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_catalog_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_episode_media_map_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_cast_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_crew_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_catalog_form_edit_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_schema.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget? buildTvMediaCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final entryDraft = draft.session.catalogItemSession;
  if (entryDraft is! TvEditDraft) {
    throw StateError(
      'TV tab "$tabId" requires the registered TV edit draft.',
    );
  }
  final tvEdit = entryDraft.tvEdit;
  final mediaEdit = entryDraft.mediaEdit;

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
    'media' => TvCatalogFormEditTab(
        state: draft,
        draft: entryDraft,
        itemId: item.reference.id,
        fieldIds: tvMainFieldIds,
        sectionLabel: 'Main',
        markDirty: markDirty,
      ),
    'edition' => TvCatalogFormEditTab(
        state: draft,
        draft: entryDraft,
        itemId: item.reference.id,
        fieldIds: tvEditionFieldIds,
        sectionLabel: 'Edition',
        markDirty: markDirty,
      ),
    'specs' => TvCatalogFormEditTab(
        state: draft,
        draft: entryDraft,
        itemId: item.reference.id,
        fieldIds: tvSpecsFieldIds,
        sectionLabel: 'Specs',
        markDirty: markDirty,
      ),
    'synopsis' => TvCatalogFormEditTab(
        state: draft,
        draft: entryDraft,
        itemId: item.reference.id,
        fieldIds: const {'synopsis'},
        sectionLabel: 'Plot',
        markDirty: markDirty,
      ),
    'cover' => TvCatalogFormEditTab(
        state: draft,
        draft: entryDraft,
        itemId: item.reference.id,
        fieldIds: const {'cover_image_url'},
        sectionLabel: 'Covers',
        markDirty: markDirty,
      ),
    'cast' => TvEditCastTab(
        accent: accent,
        state: draft,
        draft: entryDraft,
        itemId: item.reference.id,
        markDirty: markDirty,
      ),
    'crew' => TvEditCrewTab(
        accent: accent,
        tvEdit: tvEdit,
        markDirty: markDirty,
      ),
    'links' => TvEditLinksTab(
        item: item,
        accent: accent,
        userExternalLinks: draft.userExternalLinks,
        isEntry:
            draft.libraryEntry != null || draft.libraryEntryDispatch != null,
        markDirty: markDirty,
      ),
    _ => null,
  };
}
