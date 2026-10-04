import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_cast_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_crew_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_discs_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/tabs/anime_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_catalog_form_edit_tab.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_schema.dart';
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
    'main' => AnimeCatalogFormEditTab(
        state: draft,
        draft: catalogDraft,
        itemId: item.reference.id,
        fieldIds: animeMainFieldIds,
        sectionLabel: 'Main',
        markDirty: markDirty,
      ),
    'media' => AnimeCatalogFormEditTab(
        state: draft,
        draft: catalogDraft,
        itemId: item.reference.id,
        fieldIds: animeDetailsFieldIds,
        sectionLabel: 'Details',
        markDirty: markDirty,
      ),
    'edition' => AnimeCatalogFormEditTab(
        state: draft,
        draft: catalogDraft,
        itemId: item.reference.id,
        fieldIds: animeEditionFieldIds,
        sectionLabel: 'Edition',
        physicalFormatOptions: [
          for (final format in draft.physicalFormats) format.label,
        ],
        markDirty: markDirty,
      ),
    'specs' => AnimeCatalogFormEditTab(
        state: draft,
        draft: catalogDraft,
        itemId: item.reference.id,
        fieldIds: animeSpecsFieldIds,
        sectionLabel: 'Specs',
        markDirty: markDirty,
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
    'cover' => AnimeCatalogFormEditTab(
        state: draft,
        draft: catalogDraft,
        itemId: item.reference.id,
        fieldIds: animeCoverFieldIds,
        sectionLabel: 'Cover',
        markDirty: markDirty,
      ),
    'synopsis' => AnimeCatalogFormEditTab(
        state: draft,
        draft: catalogDraft,
        itemId: item.reference.id,
        fieldIds: animeSynopsisFieldIds,
        sectionLabel: 'Synopsis',
        markDirty: markDirty,
      ),
    _ => null,
  };
}
