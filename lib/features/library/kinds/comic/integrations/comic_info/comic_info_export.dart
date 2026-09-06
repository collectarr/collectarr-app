import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/actions/import_export_actions.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/comic_info/comic_info_xml.dart';
import 'package:flutter/material.dart';

/// Builds the Comic-owned export contribution consumed by a generic preview
/// host. The generic host receives only a structural artifact.
List<ExportPreviewArtifact> comicInfoExportPreviews(
  Iterable<ShelfEntry> entries,
) {
  final comicEntries = entries
      .where((entry) => entry.catalogItem?.kind == 'comic')
      .toList(growable: false);
  if (comicEntries.isEmpty) return const [];

  const xml = ComicInfoXml();
  final buffer = StringBuffer();
  var exportedCount = 0;
  for (final entry in comicEntries) {
    final catalog = entry.catalogItem;
    if (catalog == null) continue;

    final comic = ComicCoreMapper.fromCatalogItem(catalog);
    final owned = ComicOwnedItemProjection.tryFromOwnedItem(entry.ownedItem);
    if (exportedCount > 0) {
      buffer.writeln();
      buffer.writeln('<!-- --- next issue --- -->');
      buffer.writeln();
    }
    buffer.write(xml.serialize(comic, owned));
    exportedCount++;
  }
  if (exportedCount == 0) return const [];

  return [
    ExportPreviewArtifact(
      id: 'comic.comic_info_xml',
      label: 'ComicInfo.xml',
      icon: Icons.code_outlined,
      filename: 'comicinfo.xml',
      mimeType: 'application/xml',
      content: buffer.toString(),
    ),
  ];
}
