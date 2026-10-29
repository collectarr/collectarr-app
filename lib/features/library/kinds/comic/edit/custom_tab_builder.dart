import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'host_adapter.dart';
import 'draft.dart';
import 'details_tab.dart';
import 'credits_tabs.dart';
import 'links_tab.dart';
import 'main_tab.dart';
import 'value_tab.dart';
import 'personal_tab.dart';
import 'images_tabs.dart';
import 'entry/fields.dart';

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
  if (tabId == 'value') {
    final kindDraft = draft.session.catalogItemSession;
    if (kindDraft is! ComicEditDraft) {
      throw StateError('Expected ComicEditDraft for Comic entry editing');
    }
    return host.buildComicValueTab(
        collectorFields: buildComicEntryFields(
            draft: kindDraft.entryEdit, onChanged: markDirty));
  }
  return switch (tabId) {
    'main' => host.buildComicMainTab(),
    'creators' => host.buildComicCreatorsTab(),
    'characters' => host.buildComicCharactersTab(),
    'links' => host.buildComicLinksTab(),
    'personal' => host.buildComicPersonalTab(),
    'details' => host.buildComicEntryDetailsTab(),
    'cover' => host.buildComicCoverTab(),
    'photos' => host.buildComicPhotosTab(),
    _ => null,
  };
}
