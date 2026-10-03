import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
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
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final metadata = item.kindCapability.mapTransport(
      (transport) => ComicCatalogItem.fromJson(transport.kindData));
  if (metadata is! ComicCatalogItem) {
    throw StateError('Expected ComicCatalogItem for comic edit tabs');
  }
  final media = metadata.id?.value == item.reference.id
      ? metadata
      : metadata.copyWith(id: ComicCatalogItemId(item.reference.id));
  final host = ComicEditHostAdapter(
    context: context,
    draft: draft,
    media: media,
    accent: accent,
    scope: scope,
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
