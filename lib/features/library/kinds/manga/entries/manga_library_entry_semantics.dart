import 'package:collectarr_app/features/library/kinds/manga/catalog/manga_catalog_fields.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryEntryFormatHint resolveMangaEntryFormatHint(
  CatalogSearchCandidate item,
) {
  final transport = item.kindCapability.mapTransport((transport) => transport);
  final format = transport.physicalFormat;
  return (
    format: format,
    label: transport.physicalFormatLabel ??
        format ??
        (item.mangaCatalogFields.titleExtension ?? transport.editionTitle)
            ?.trim(),
  );
}

bool? resolveMangaEntryDigitalFlag(
  LibraryEntrySummary? libraryEntry, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: libraryEntry?.isDigital,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? mangaPhysicalMediaFormats : formats,
  );
}
