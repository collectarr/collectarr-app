import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

import 'comic_edit_host_adapter.dart';
import 'comic_edit_tabs.dart';

Widget? buildComicCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditDraft draft,
  required Color accent,
  required LibraryEditScope scope,
  required LibraryMetadataItem item,
  required VoidCallback markDirty,
}) {
  final metadata = item.kindMetadata;
  if (metadata is! ComicCatalogMetadata) {
    throw StateError('Expected ComicCatalogMetadata for comic edit tabs');
  }
  final catalogItem = ComicCatalogMapper.mapMetadataToComic(
    metadata,
    id: item.identity.id,
  );
  final host = ComicEditHostAdapter(
    context: context,
    draft: draft,
    catalogItem: catalogItem,
    accent: accent,
    scope: scope,
    markDirty: markDirty,
  );
  return switch (tabId) {
    'main' => host.buildComicMainTab(),
    'creators' => host.buildComicCreatorsTab(),
    'characters' => host.buildComicCharactersTab(),
    'links' => host.buildComicLinksTab(),
    'value' => host.buildComicValueTab(),
    'personal' => host.buildComicPersonalTab(),
    'details' => host.buildComicOwnedDetailsTab(),
    'cover' => host.buildComicCoverTab(),
    'photos' => host.buildComicPhotosTab(),
    _ => null,
  };
}
