import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/movie_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_cast_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit/tabs/movie_crew_tab.dart';
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
      ),
    'cast' => MovieEditCastTab(
        movieEdit: movieEdit,
        accent: accent,
        markDirty: markDirty,
      ),
    'crew' => MovieEditCrewTab(
        movieEdit: movieEdit,
        accent: accent,
        markDirty: markDirty,
      ),
    'links' => MovieEditLinksTab(
        item: item,
        accent: accent,
        userExternalLinks: draft.userExternalLinks,
        isEntry:
            draft.libraryEntry != null || draft.libraryEntryDispatch != null,
        markDirty: markDirty,
      ),
    'catalog_item' => MovieEditCatalogItemTab(
        draft: draft,
        movieEdit: movieEdit,
        accent: accent,
        genreOptions: draft.kindVocabularies[MovieVocabularyIds.genre.value] ??
            MovieVocabularies.genre.builtIns,
      ),
    _ => null,
  };
}
