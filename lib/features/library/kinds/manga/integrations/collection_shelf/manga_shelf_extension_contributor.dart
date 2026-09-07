import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_shelf_extension_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_shelf/manga_collection_shelf_extension.dart';
import 'package:flutter/material.dart';

final class MangaShelfExtensionContributor
    implements LibraryShelfExtensionContributor {
  const MangaShelfExtensionContributor();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  Widget? build(
    ShelfEntry entry, {
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    return MangaCollectionShelfExtension(
      itemId: entry.itemId,
      expanded: expanded,
      onToggle: onToggle,
    );
  }
}
