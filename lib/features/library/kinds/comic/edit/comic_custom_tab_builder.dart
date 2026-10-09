import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'comic_edit_host_adapter.dart';
import 'comic_edit_draft.dart';
import 'comic_edit_tabs.dart';
import 'entry/comic_entry_edit_tab.dart';

Widget? buildComicCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final metadata = item.kindCapability.mapTransport(
      (transport) => ComicCatalogItem.fromJson(transport.kindData));
  final catalogRef = draft.target?.catalogItemRef ?? item.catalogRef;
  final media = catalogRef == null || metadata.id == catalogRef
      ? metadata
      : metadata.copyWith(id: catalogRef);
  final host = ComicEditHostAdapter(
    context: context,
    draft: draft,
    media: media,
    accent: accent,
    markDirty: markDirty,
  );
  if (tabId == 'entry') {
    final kindDraft = draft.session.catalogItemSession;
    if (kindDraft is! ComicEditDraft) {
      throw StateError('Expected ComicEditDraft for Comic entry editing');
    }
    return buildComicEntryEditSchemaTab(comicDraft: kindDraft);
  }
  return switch (tabId) {
    'main' => host.buildComicMainTab(),
    'creators' => host.buildComicCreatorsTab(),
    'characters' => host.buildComicCharactersTab(),
    'links' => host.buildComicLinksTab(),
    'value' => host.buildComicValueTab(),
    'personal' => host.buildComicPersonalTab(),
    'details' => host.buildComicEntryDetailsTab(),
    'cover' => host.buildComicCoverTab(),
    'photos' => host.buildComicPhotosTab(),
    _ => null,
  };
}
