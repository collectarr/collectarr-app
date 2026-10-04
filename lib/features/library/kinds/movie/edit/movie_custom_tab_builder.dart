import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_cast_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_crew_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_discs_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_edition_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_catalog_item_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_specs_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget? buildMovieCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final catalogDraft = draft.session.catalogItemSession;
  if (catalogDraft is! MovieEditDraftContract) {
    throw StateError(
      'Movie tab "$tabId" requires the registered Movie edit draft.',
    );
  }
  final movieEdit = catalogDraft.movieEdit;

  return switch (tabId) {
    'edition' => MovieEditEditionTab(
        movieEdit: movieEdit,
        accent: accent,
        physicalFormats: draft.physicalFormats,
      ),
    'specs' => MovieEditSpecsTab(
        movieDraft: catalogDraft,
        accent: accent,
        audioTrackOptions:
            draft.kindVocabularies[MovieVocabularyIds.audio.value] ?? const [],
        subtitleOptions:
            draft.kindVocabularies[MovieVocabularyIds.subtitles.value] ??
                const [],
        layersOptions: const [],
        colorOptions: const [],
      ),
    'cast' => MovieEditCastTab(
        accent: accent,
        movieEdit: movieEdit,
        markDirty: markDirty,
      ),
    'crew' => MovieEditCrewTab(
        accent: accent,
        movieEdit: movieEdit,
        markDirty: markDirty,
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
    'catalog_item' => MovieEditCatalogItemTab(
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
