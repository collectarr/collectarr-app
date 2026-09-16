import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_cast_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_crew_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_discs_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_edition_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_specs_tab.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget? buildMovieCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditDraft draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final movieEdit = (draft.kindDetails is MovieEditDraftContract)
      ? (draft.kindDetails as MovieEditDraftContract).movieEdit
      : MovieEditController(itemId: item.id, catalogRef: item.catalogRef);

  return switch (tabId) {
    'edition' => MovieEditEditionTab(
        draft: draft,
        accent: accent,
        physicalFormats: const [],
      ),
    'specs' => MovieEditSpecsTab(
        draft: draft,
        movieEdit: movieEdit,
        accent: accent,
        audioTrackOptions: const [],
        subtitleOptions: const [],
        layersOptions: const [],
        colorOptions: const [],
      ),
    'cast' => MovieEditCastTab(
        accent: accent,
        movieEdit: movieEdit,
      ),
    'crew' => MovieEditCrewTab(
        accent: accent,
        movieEdit: movieEdit,
      ),
    'discs' => MovieEditDiscsTab(
        item: item,
        accent: accent,
      ),
    'links' => MovieEditLinksTab(
        item: item,
        accent: accent,
        movieEdit: movieEdit,
      ),
    'media' => MovieEditMediaTab(
        draft: draft,
        movieEdit: movieEdit,
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
