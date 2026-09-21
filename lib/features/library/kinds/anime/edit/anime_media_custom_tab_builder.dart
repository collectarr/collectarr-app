import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_controller.dart';
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
  final animeEdit = (draft.kindDetails is AnimeEditDraftContract)
      ? (draft.kindDetails as AnimeEditDraftContract).animeEdit
      : AnimeEditController(itemId: item.id, catalogRef: item.catalogRef);

  return switch (tabId) {
    'edition' => AnimeEditEditionTab(
        draft: draft,
        accent: accent,
        physicalFormats: const [],
      ),
    'specs' => AnimeEditSpecsTab(
        draft: draft,
        animeEdit: animeEdit,
        accent: accent,
        audioTrackOptions: const [],
        subtitleOptions: const [],
        layersOptions: const [],
        colorOptions: const [],
      ),
    'cast' => AnimeEditCastTab(
        accent: accent,
        animeEdit: animeEdit,
      ),
    'crew' => AnimeEditCrewTab(
        accent: accent,
        animeEdit: animeEdit,
      ),
    'discs' => AnimeEditDiscsTab(
        item: item,
        accent: accent,
      ),
    'links' => AnimeEditLinksTab(
        item: item,
        accent: accent,
        animeEdit: animeEdit,
      ),
    'media' => AnimeEditMediaTab(
        draft: draft,
        animeEdit: animeEdit,
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
