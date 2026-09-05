import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

import 'music_edit_draft.dart';
import 'music_links_tab.dart';

Widget? buildMusicCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditDraft draft,
  required Color accent,
  required LibraryEditScope scope,
  required CatalogItem item,
  required VoidCallback markDirty,
}) {
  final musicDraft = draft.kindDetails as MusicEditDraft?;
  if (musicDraft == null) return null;

  return switch (tabId) {
    'links' => MusicLinksTab(
        draft: musicDraft,
        accent: accent,
        markDirty: markDirty,
      ),
    _ => null,
  };
}
