import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tv_edit_draft_contract.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_cast_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_crew_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_edition_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_media_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/tabs/tv_specs_tab.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
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
  if (entryDraft is! TvEditDraftContract) {
    throw StateError(
      'TV tab "$tabId" requires the registered TV edit draft.',
    );
  }
  final tvEdit = entryDraft.tvEdit;

  return switch (tabId) {
    'edition' => TvEditEditionTab(
        tvEdit: tvEdit,
        accent: accent,
        physicalFormats: draft.physicalFormats,
      ),
    'specs' => TvEditSpecsTab(
        tvDraft: entryDraft,
        accent: accent,
        audioTrackOptions:
            draft.kindVocabularies[TvVocabularyIds.audio.value] ?? const [],
        subtitleOptions:
            draft.kindVocabularies[TvVocabularyIds.subtitles.value] ?? const [],
      ),
    'cast' => TvEditCastTab(
        accent: accent,
        tvEdit: tvEdit,
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
        tvEdit: tvEdit,
      ),
    'media' => TvEditMediaTab(
        draft: draft,
        tvEdit: tvEdit,
        accent: accent,
      ),
    _ => null,
  };
}
