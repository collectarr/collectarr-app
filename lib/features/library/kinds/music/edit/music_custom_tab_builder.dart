import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:flutter/material.dart';

import 'music_edit_draft.dart';
import 'music_links_tab.dart';

Widget? buildMusicCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditDraft draft,
  required Color accent,
  required LibraryEditScope scope,
  required LibraryAddCatalogTransport item,
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
