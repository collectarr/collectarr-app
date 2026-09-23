import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_cast_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_crew_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_discs_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_edition_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_specs_tab.dart';
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
  final tvEdit = (draft.session.workSession is TvEditDraftContract)
      ? (draft.session.workSession as TvEditDraftContract).tvEdit
      : TvEditController(itemId: item.reference.id, catalogRef: item.reference);

  return switch (tabId) {
    'edition' => TvEditEditionTab(
        draft: draft,
        accent: accent,
        physicalFormats: const [],
      ),
    'specs' => TvEditSpecsTab(
        draft: draft,
        tvEdit: tvEdit,
        accent: accent,
        audioTrackOptions: const [],
        subtitleOptions: const [],
        layersOptions: const [],
        colorOptions: const [],
      ),
    'cast' => TvEditCastTab(
        accent: accent,
        tvEdit: tvEdit,
      ),
    'crew' => TvEditCrewTab(
        accent: accent,
        tvEdit: tvEdit,
      ),
    'discs' => TvEditDiscsTab(
        item: item,
        accent: accent,
      ),
    'links' => TvEditLinksTab(
        item: item,
        accent: accent,
        tvEdit: tvEdit,
      ),
    'media' => TvEditMediaTab(
        draft: draft,
        tvEdit: tvEdit,
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
