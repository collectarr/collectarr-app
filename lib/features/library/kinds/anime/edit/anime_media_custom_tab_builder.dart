import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_cast_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_crew_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_discs_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_edition_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_specs_tab.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget? buildAnimeMediaCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final catalogDraft = draft.session.catalogItemSession;
  if (catalogDraft is! AnimeEditDraftContract) {
    throw StateError(
      'Anime tab "$tabId" requires the registered Anime edit draft.',
    );
  }
  final animeEdit = catalogDraft.animeEdit;

  return switch (tabId) {
    'edition' => AnimeEditEditionTab(
        draft: draft,
        animeDraft: catalogDraft,
        accent: accent,
        physicalFormats: draft.physicalFormats,
      ),
    'specs' => AnimeEditSpecsTab(
        animeDraft: catalogDraft,
        accent: accent,
      ),
    'cast' => AnimeEditCastTab(
        accent: accent,
        animeEdit: animeEdit,
        markDirty: markDirty,
      ),
    'crew' => AnimeEditCrewTab(
        accent: accent,
        animeEdit: animeEdit,
        markDirty: markDirty,
      ),
    'discs' => AnimeEditDiscsTab(
        item: item,
        accent: accent,
      ),
    'links' => AnimeEditLinksTab(
        item: item,
        accent: accent,
        userExternalLinks: draft.userExternalLinks,
        isEntry:
            draft.libraryEntry != null || draft.libraryEntryDispatch != null,
        markDirty: markDirty,
      ),
    'media' => AnimeEditMediaTab(
        draft: draft,
        accent: accent,
        animeEdit: animeEdit,
        markDirty: markDirty,
      ),
    _ => null,
  };
}
