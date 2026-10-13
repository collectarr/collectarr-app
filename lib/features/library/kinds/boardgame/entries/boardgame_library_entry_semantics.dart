import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_fields.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryEntryFormatHint resolveBoardGameEntryFormatHint(
  CatalogSearchCandidate item,
) {
  final metadata = item.boardGameCatalogFields.metadata;
  final format = metadata?.physicalFormat;
  return (
    format: format,
    label: metadata?.physicalFormatLabel ??
        format ??
        (item.boardGameCatalogFields.titleExtension ?? metadata?.editionTitle)
            ?.trim(),
  );
}

bool? resolveBoardGameEntryDigitalFlag(
  LibraryEntrySummary? libraryEntry, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: libraryEntry?.isDigital,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? boardGamePhysicalMediaFormats : formats,
  );
}
